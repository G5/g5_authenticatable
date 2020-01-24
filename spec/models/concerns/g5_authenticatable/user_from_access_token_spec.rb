require 'rails_helper'

RSpec.describe G5Authenticatable::UserFromAccessToken do
  let(:request) { double(:request, params: {}, headers: {}) }
  let(:warden) { double(:warden) }
  let(:location) { FactoryBot.create(:g5_updatable_location) }
  let(:client) { location.client }
  let(:client_urn) { client.urn }
  subject { G5Authenticatable::User.find_or_create_from_access_token_request(request, warden) }
  let(:global_client_user) do
    { "id"                                  => 8,
      "email"                               => "perry.hertler+byron@getg5.com",
      "first_name"                          => "perry",
      "last_name"                           => "byron",
      "phone_number"                        => "2332223333",
      "organization_name"                   => nil,
      "title"                               => nil,
      "roles"                               => [{ "name" => "admin", "type" => "G5Updatable::Client", "urn" => client_urn }],
      "accessible_applications"             => [{ "url" => "global", "accessible_products" => [] }],
      "restricted_application_redirect_url" => "" }
  end
  let(:super_admin_user) do
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
  let(:api_user) { G5AuthenticationClient::User.new(user_hash) }
  let(:user_fetcher) do
    instance_double(G5AuthenticatableApi::Services::UserFetcher,
                    current_user: api_user,
                    access_token: access_token)
  end
  before do
    allow(G5AuthenticatableApi::Services::UserFetcher).to receive(:new).and_return(user_fetcher)
  end

  context 'super admin' do
    let(:user_hash) { super_admin_user }
    it 'creates the authenticatable user' do
      expect { subject }.to change { G5Authenticatable::User.count }.by(1)
      expect(G5Authenticatable::User.find_by(email: super_admin_user['email'])).to be_present
    end

    it 'creates super admin role' do
      expect { subject }.to change { G5Authenticatable::Role.count }.by(1)
      expect(G5Authenticatable::Role.last.name).to eq('super_admin')
    end

    it 'instantiates UserFetcher correctly' do
      subject
      expect(G5AuthenticatableApi::Services::UserFetcher).to have_received(:new).with(request.params,
                                                                                      request.headers,
                                                                                      warden)
    end
  end

  context 'client admin' do
    let(:user_hash) { global_client_user }
    it 'creates the authenticatable user' do
      expect { subject }.to change { G5Authenticatable::User.count }.by(1)
      expect(G5Authenticatable::User.find_by(email: global_client_user['email'])).to be_present
    end

    it 'creates client role' do
      expect { subject }.to change { G5Authenticatable::Role.count }.by(1)
      created_role = G5Authenticatable::User.last.roles.first
      expect(created_role.name).to eq('admin')
      expect(created_role.resource_type).to eq('G5Updatable::Client')
      expect(created_role.resource_id).to eq(client.id)
    end
  end

  context 'user already exists' do
    let(:user_hash) { global_client_user }
    let!(:already_exists) do
      user = G5Authenticatable::User.new(provider:        :g5,
                                         uid:             33,
                                         g5_access_token: 'token')
      user.assign_attributes(api_user.except(:roles, :id))
      user.save
      user
    end

    it 'creates admin role' do
      expect { subject }.to change { G5Authenticatable::Role.count }.by(1)
      expect(G5Authenticatable::Role.last.name).to eq('admin')
    end
  end
end