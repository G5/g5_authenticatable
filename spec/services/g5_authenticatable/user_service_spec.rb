require 'rails_helper'

RSpec.describe G5Authenticatable::UserService do
  let(:request) { double(:request, params: {}, headers: {}) }
  let(:warden) { double(:warden) }
  let(:user_fetcher) do
    instance_double(G5AuthenticatableApi::Services::UserFetcher,
                    current_user: auth_user,
                    access_token: access_token)
  end
  let(:user_hash) do
    { "id"                                  => 4,
      "email"                               => "perry.hertler+test-auth@getg5.com",
      "first_name"                          => "Perry",
      "last_name"                           => "TestUser",
      "phone_number"                        => "3073301111",
      "organization_name"                   => nil,
      "title"                               => nil,
      "roles"                               => [{ "name" => "super_admin", "type" => "GLOBAL", "urn" => nil }],
      "accessible_applications"             => [{ "url" => "global", "accessible_products" => [] }],
      "restricted_application_redirect_url" => "" }
  end
  let(:access_token) { 'afds' }
  let(:auth_user) { G5AuthenticationClient::User.new(user_hash) }
  let(:user_fetcher) do
    instance_double(G5AuthenticatableApi::Services::UserFetcher,
                    current_user: auth_user,
                    access_token: access_token)
  end
  describe '#find_or_create_from_access_token_request' do
    subject { described_class.find_or_create_from_access_token_request(request, warden) }
    context 'success' do
      before do
        allow(G5AuthenticatableApi::Services::UserFetcher).to receive(:new).and_return(user_fetcher)
        allow(G5Authenticatable::User).to receive(:create_or_find_from_auth_user).and_return('new user')
      end

      it 'delegates to User.create_or_find_from_auth_user' do
        expect(subject).to eq('new user')
        expect(G5Authenticatable::User).to have_received(:create_or_find_from_auth_user).with(auth_user: auth_user, g5_access_token: access_token)
      end

      it 'instantiates user fetcher' do
        subject
        expect(G5AuthenticatableApi::Services::UserFetcher).to have_received(:new).with(request.params, request.headers, warden)
      end
    end
  end
end