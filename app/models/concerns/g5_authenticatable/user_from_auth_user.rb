module G5Authenticatable
  module UserFromAuthUser
    extend ActiveSupport::Concern

    class_methods do
      def create_or_find_from_auth_user(params)
        CreateOrFindFromAuthUser.execute(params)
      end
    end

    class CreateOrFindFromAuthUser
      attr_reader :user, :auth_user, :g5_access_token

      def initialize(params)
        params.keys.each do |key|
          instance_variable_set("@#{key}", params[key])
        end
      end

      def self.execute(params)
        new(params).execute
      end

      def execute
        @user = G5Authenticatable::User.find_by(email: auth_user.email)
        create_user unless user
        add_auth_user_roles
        user
      end

      def create_user
        @user = G5Authenticatable::User.new(provider:        :g5,
                                            uid:             auth_user.id,
                                            g5_access_token: g5_access_token)
        user.assign_attributes(auth_user.except(:roles, :id))

        user.save
      end

      def add_auth_user_roles
        user.roles.clear
        auth_user.roles.each do |role|
          role.type == G5Authenticatable::User::GLOBAL_ROLE ? user.add_role(role.name) : user.add_scoped_role(role)
        end
      end
    end
  end
end