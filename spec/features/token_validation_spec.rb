# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'UI Token validation' do
  context 'when token validation is enabled' do
    before { G5Authenticatable.strict_token_validation = true }

    context 'when user has a valid g5 access token' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      before do
        stub_g5_omniauth(user)
        stub_valid_access_token(user.g5_access_token)
        visit protected_page_path

        # Now that we're logged in, any subsequent attempts to
        # authenticate with the auth server will trigger an omniauth
        # failure, which is a condition we can test for
        stub_g5_invalid_credentials
      end

      it 'should allow the user to visit a protected page' do
        visit protected_page_path
        expect(current_path).to eq(protected_page_path)
      end
    end

    context 'when user access token becomes invalid' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      before do
        # User access token is valid at sign in
        stub_g5_omniauth(user)
        stub_valid_access_token(user.g5_access_token)
        visit protected_page_path

        # User access token has become invalid, and
        # any subsequent attempts to authenticate will trigger
        # an omniauth error
        stub_invalid_access_token(user.g5_access_token)
        stub_g5_invalid_credentials
      end

      it 'should force the user to re-authenticate' do
        visit protected_page_path
        expect(current_path).to_not eq(protected_page_path)
      end
    end

    context 'when using the :auth shared context', :auth do
      it 'should allow the user to visit a protected page' do
        visit protected_page_path
        expect(current_path).to eq(protected_page_path)
      end
    end
  end

  context 'when token validation is disabled' do
    before { G5Authenticatable.strict_token_validation = false }

    context 'when using the :auth shared context', :auth do
      it 'should allow the user to visit a protected page' do
        visit protected_page_path
        expect(current_path).to eq(protected_page_path)
      end
    end

    context 'when user access token has become invalid' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      before do
        stub_g5_omniauth(user)
        visit protected_page_path

        # Now that we're already logged in, invalidate the
        # access token
        stub_g5_invalid_credentials
        stub_invalid_access_token(user.g5_access_token)
      end

      it 'should allow the user to visit a protected page' do
        visit protected_page_path
        expect(current_path).to eq(protected_page_path)
      end
    end
  end
end
