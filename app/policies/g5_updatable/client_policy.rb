# frozen_string_literal: true

# Clients defined by this policy are ones for whom the user has access at the
# client level. This means that either they have a global role or they have
# a specific client role.
module G5Updatable
  class ClientPolicy < G5Authenticatable::BasePolicy
    class Scope < G5Authenticatable::BasePolicy::BaseScope
      def resolve
        return scope.all if has_global_role?
        client_with_roles
      end

      private

      def client_with_roles
        G5Updatable::Client
          .joins('INNER JOIN g5_authenticatable_roles as r ON r.resource_id = g5_updatable_clients.id')
          .joins('INNER JOIN g5_authenticatable_users_roles as ur ON r.id = ur.role_id')
          .where('r.resource_type = ? and ur.user_id = ?', G5Updatable::Client.name, user.id)
      end
    end
  end
end
