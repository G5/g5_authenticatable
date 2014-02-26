require 'spec_helper'

describe 'a secure Rails API' do
  describe 'POST request to an API-only action' do
    subject(:api_call) { post '/rails_api/secure_resource' }

    context 'with an authenticated user', :auth_request do
      it 'should be successful' do
        api_call
        expect(response).to be_http_ok
      end
    end

    context 'without an authenticated user' do
      it 'should be unauthorized' do
        api_call
        expect(response).to be_http_unauthorized
      end
    end
  end

  describe 'GET json request to mixed API/website action' do
    subject(:api_call) { get '/rails_api/secure_resource.json' }

    context 'with an authenticated user', :auth_request do
      it 'should be successful' do
        api_call
        expect(response).to be_http_ok
      end
    end

    context 'without an authenticated user' do
      it 'should be unauthorized' do
        api_call
        expect(response).to be_http_unauthorized
      end
    end
  end

  describe 'GET html request to mixed API/website action' do
    subject(:website_call) { get '/rails_api/secure_resource.html' }

    it 'should be a redirect' do
      website_call
      expect(response).to be_redirect
    end

    it 'should redirect to the new session path' do
      website_call
      expect(response).to redirect_to('/g5_auth/users/sign_in')
    end
  end
end
