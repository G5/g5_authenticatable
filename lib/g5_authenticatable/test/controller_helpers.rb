# frozen_string_literal: true

module G5Authenticatable
  module Test
    # Helper methods for controller tests
    module ControllerHelpers
      def login_user(user)
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
      end

      def logout_user(user)
        sign_out(user)
      end
    end
  end
end

RSpec.shared_context 'auth controller' do
  let(:user) { FactoryBot.create(:g5_authenticatable_user) }
  include_context 'authorization controller'
end

RSpec.shared_context 'super admin auth controller' do
  let(:user) do
    user = FactoryBot.create(:g5_authenticatable_user)
    user.add_role(:super_admin)
    user
  end
  include_context 'authorization controller'
end

RSpec.shared_context 'admin auth controller' do
  let(:user) do
    user = FactoryBot.create(:g5_authenticatable_user)
    user.add_role(:admin)
    user
  end
  include_context 'authorization controller'
end

RSpec.shared_context 'authorization controller' do
  include G5Authenticatable::Test::ControllerHelpers

  before do
    stub_valid_access_token(user.g5_access_token)
    login_user(user)
  end

  after { logout_user(user) }
end

RSpec.shared_examples 'a secure controller' do
  controller do
    before_action :authenticate_user!

    def index
      render plain: 'content'
    end
  end

  context 'without an authenticated user' do
    it 'should be redirected' do
      get :index
      expect(response).to redirect_to('/g5_auth/users/sign_in')
    end
  end

  context 'with an authenticated user', :auth_controller do
    it 'should be successful' do
      get :index
      expect(response.body).to eq('content')
    end
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include G5Authenticatable::Test::ControllerHelpers, type: :controller

  config.include_context 'auth controller', auth_controller: true
end
