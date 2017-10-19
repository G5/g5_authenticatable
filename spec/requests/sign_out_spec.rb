# frozen_string_literal: true

require 'rails_helper'

# Normally, we'd do this as a feature spec, but there's
# currently no easy way to get capybara to play along nicely
# with mocks for external redirects (the capybara-mechanize driver
# comes closest, but not quite)
RSpec.describe 'Signing out' do
  let(:auth_sign_out_url) do
    "#{ENV['G5_AUTH_ENDPOINT']}/users/sign_out" \
      '?redirect_url=http%3A%2F%2Fwww.example.com%2F'
  end

  describe 'GET /g5_auth/users/sign_out' do
    subject(:sign_out) { safe_get '/g5_auth/users/sign_out' }

    context 'when user is logged in', :auth_request do
      it 'should redirect to the auth server' do
        expect(sign_out).to redirect_to(auth_sign_out_url)
      end

      it 'should not allow the user to access protected pages' do
        sign_out
        expect(safe_get('/protected_page'))
          .to redirect_to('/g5_auth/users/sign_in')
      end
    end

    context 'when user is not logged in' do
      it 'should redirect to the auth server' do
        expect(sign_out).to redirect_to(auth_sign_out_url)
      end
    end
  end

  describe 'DELETE /g5_auth/users/sign_out', :auth_request do
    subject(:sign_out) { safe_delete '/g5_auth/users/sign_out' }

    it 'should redirect to GET' do
      expect(sign_out).to redirect_to('/g5_auth/users/sign_out')
    end
  end
end
