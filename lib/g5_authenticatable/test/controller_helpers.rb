module G5Authenticatable
  module Test
    module ControllerHelpers

      def login_user(user)
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in user
      end

      def logout_user(user)
        sign_out(user)
      end

    end
  end
end

shared_context 'auth controller', auth_controller: true do
  include G5Authenticatable::Test::ControllerHelpers
  let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

  before { login_user(user) }
  after { logout_user(user) }
end

shared_examples 'a secure controller' do

  controller do

    before_filter :authenticate_user!

    def index
      render text: 'content'
    end
  end

  context "without an authenticated user" do

    it "should be redirected" do
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
  config.include Devise::TestHelpers, :type => :controller
  config.include G5Authenticatable::Test::ControllerHelpers, type: :controller
end
