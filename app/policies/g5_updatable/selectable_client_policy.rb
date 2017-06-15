# frozen_string_literal: true

# Policy to define which clients are show to users to select. This includes all
# clients for whom a user only has a location scoped role.  Clients defined by
# this policy are not necessarily granted view permissions at the client level.
module G5Updatable
  class SelectableClientPolicy < G5Authenticatable::BasePolicy
    class Scope < G5Authenticatable::BasePolicy::BaseScope
      def resolve
        clients_from_client_and_location_roles
      end

      def client_roles
        G5Authenticatable::Role
          .joins('INNER JOIN g5_updatable_clients as c ON c.id = g5_authenticatable_roles.resource_id')
          .joins('INNER JOIN g5_authenticatable_users_roles as ur ON g5_authenticatable_roles.id = ur.role_id')
          .where('g5_authenticatable_roles.resource_type = ? and ur.user_id = ?', G5Updatable::Client.name, user.id)
      end

      def clients_from_client_and_location_roles
        return scope.all if has_global_role?
        client_ids = clients_from_location_roles.map(&:id) | client_roles.map(&:resource_id)
        G5Updatable::Client.where(id: client_ids)
      end

      def clients_from_location_roles
        G5Updatable::Client
          .joins('INNER JOIN g5_updatable_locations as l on l.client_uid=g5_updatable_clients.uid')
          .joins('INNER JOIN g5_authenticatable_roles as r on l.id=r.resource_id')
          .joins('INNER JOIN g5_authenticatable_users_roles as ur on r.id=ur.role_id')
          .where('r.resource_type = ? and ur.user_id = ?',
                 G5Updatable::Location.name, user.id)
          .group('g5_updatable_clients.id')
      end
    end
  end
end
