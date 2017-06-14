module G5Authenticatable
  module Test
    module FeatureHelpers
      def stub_g5_omniauth(user, options={})
        OmniAuth.config.mock_auth[:g5] = OmniAuth::AuthHash.new({
          uid: user.uid,
          provider: 'g5',
          info: {
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            phone: user.phone_number
          },
          credentials: {token: user.g5_access_token},
          extra: {
            title: user.title,
            organization_name: user.organization_name,
            roles: user.roles.collect do |role|
              {name: role.name, type: 'GLOBAL', urn: nil}
            end,
            raw_info: {}
          }
        }.merge(options))
      end

      def stub_g5_invalid_credentials
        OmniAuth.config.mock_auth[:g5] = :invalid_credentials
      end

      def visit_path_and_login_with(path, user)
        stub_g5_omniauth(user)
        stub_valid_access_token(user.g5_access_token)
        visit path
      end
    end
  end
end

RSpec.shared_context 'auth', auth: true do
  include G5Authenticatable::Test::FeatureHelpers

  let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

  before do
    stub_g5_omniauth(user)
    stub_valid_access_token(user.g5_access_token)
  end
end

RSpec.configure do |config|
  config.before(:each) { OmniAuth.config.test_mode = true }
  config.after(:each) { OmniAuth.config.test_mode = false }

  config.include G5Authenticatable::Test::FeatureHelpers, type: :feature
end
