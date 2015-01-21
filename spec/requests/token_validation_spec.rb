require 'spec_helper'

describe 'API Token validation' do
  let!(:old_auth_endpoint) { ENV['G5_AUTH_ENDPOINT'] }
  before { ENV['G5_AUTH_ENDPOINT'] = auth_endpoint }
  after { ENV['G5_AUTH_ENDPOINT'] = old_auth_endpoint }
  let(:auth_endpoint) { 'https://auth.test.host' }

  let(:token_info_url) { URI.join(auth_endpoint, '/oauth/token/info') }

  subject(:api_call) { get '/rails_api/secure_resource.json' }

  context 'when token validation is enabled' do
    before { G5Authenticatable.strict_token_validation = true }

    context 'when user has a valid g5 access token' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      before do
        login_user(user)
        stub_valid_access_token(user.g5_access_token)
      end

      after { logout_user }

      it 'should allow the user to make the api call' do
        api_call
        expect(response).to be_success
      end
    end

    context 'when user has an invalid g5 access token' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      before do
        login_user(user)
        stub_invalid_access_token(user.g5_access_token)
      end

      after { logout_user }

      it 'should return a 401' do
        api_call
        expect(response).to be_http_unauthorized
      end
    end

    context 'with the :auth_request shared context', :auth_request do
      it 'should allow the user to make the api call' do
        api_call
        expect(response).to be_success
      end
    end
  end

  context 'when token validation is disabled' do
    before { G5Authenticatable.strict_token_validation = false }

    context 'when the user has an invalid g5 access token' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      before do
        login_user(user)
        stub_invalid_access_token(user.g5_access_token)
      end

      after { logout_user }

      it 'should allow the user to make the api call' do
        api_call
        expect(response).to be_success
      end
    end

    context 'with the :auth_request shared context', :auth_request do
      it 'should allow the user to make the api call' do
        api_call
        expect(response).to be_success
      end
    end
  end
end
