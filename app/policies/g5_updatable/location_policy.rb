# frozen_string_literal: true

# The policy will resolve to all locations that a user has access. This includes
# locations that a user has roles for but also those locations for which a user
# has a client role.  Global roles grant access to ALL locations.
module G5Updatable
  class LocationPolicy < G5Authenticatable::BasePolicy
    class Scope < G5Authenticatable::BasePolicy::BaseScope
      def resolve
        locations_from_client_location_roles
      end

      private

      def location_roles
        G5Authenticatable::Role
          .joins('INNER JOIN g5_updatable_locations as l ON l.id = g5_authenticatable_roles.resource_id')
          .joins('INNER JOIN g5_authenticatable_users_roles as ur ON g5_authenticatable_roles.id = ur.role_id')
          .where('g5_authenticatable_roles.resource_type = ? and ur.user_id = ?',
                 G5Updatable::Location.name, user.id)
      end

      def locations_from_client_roles
        G5Updatable::Location
          .joins('INNER JOIN g5_updatable_clients as c on g5_updatable_locations.client_uid=c.uid')
          .joins('INNER JOIN g5_authenticatable_roles as r on r.resource_id=c.id')
          .joins('INNER JOIN g5_authenticatable_users_roles as ur on r.id=ur.role_id')
          .where('ur.user_id=?',user.id)
          .where('r.resource_type=?', G5Updatable::Client.name)
      end

      def locations_from_client_location_roles
        return scope.all if has_global_role?
        location_ids = locations_from_client_roles.map(&:id) | location_roles.map(&:resource_id)
        G5Updatable::Location.where(id: location_ids)
      end
    end
  end
end
