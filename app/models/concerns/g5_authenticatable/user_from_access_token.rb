module G5Authenticatable
  module UserFromAccessToken
    extend ActiveSupport::Concern

    class_methods do
      def find_or_create_from_access_token_request(request, warden)
        CreateOrFindAuthUser.create_or_find_current_api_user(request, warden)
      end
    end

    class CreateOrFindAuthUser
      attr_reader :user, :request, :warden

      def initialize(request, warden)
        @request = request
        @warden  = warden
      end

      def self.create_or_find_current_api_user(request, warden)
        new(request, warden).create_or_find_current_api_user
      end

      def create_or_find_current_api_user
        @user = G5Authenticatable::User.find_by(email: api_user.email)
        create_user unless user
        add_api_user_roles
        user
      end

      def create_user
        @user = G5Authenticatable::User.new(provider:        :g5,
                                            uid:             api_user.id,
                                            g5_access_token: api_user_fetcher.access_token)
        user.assign_attributes(api_user.except(:roles, :id))

        user.save
      end

      def add_api_user_roles
        user.roles.clear
        api_user.roles.each do |role|
          role.type == G5Authenticatable::User::GLOBAL_ROLE ? user.add_role(role.name) : user.add_scoped_role(role)
        end
      end

      def api_user
        @api_user ||= api_user_fetcher.current_user
      end

      def api_user_fetcher
        @api_user_fetcher ||= G5AuthenticatableApi::Services::UserFetcher.new(request.params, request.headers, warden)
      end
    end
  end
end