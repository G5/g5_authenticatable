module G5Authenticatable
  class User < ActiveRecord::Base
    devise :g5_authenticatable, :trackable, :timeoutable
    rolify role_cname: 'G5Authenticatable::Role',
           role_join_table_name: :g5_authenticatable_users_roles

    validates :email, presence: true, uniqueness: true
    validates_uniqueness_of :uid, scope: :provider

    GLOBAL_ROLE = 'GLOBAL'

    def attributes_from_auth(auth_data)
      super(auth_data).merge({
        first_name: auth_data.info.first_name,
        last_name: auth_data.info.last_name,
        phone_number: auth_data.info.phone,
        title: auth_data.extra.title,
        organization_name: auth_data.extra.organization_name
      })
    end

    def update_roles_from_auth(auth_data)
      roles.clear
      auth_data.extra.roles.each do |role|
        role.type == GLOBAL_ROLE ? add_role(role.name) : add_scoped_role(role)
      end
    end

    def selectable_clients
      G5Updatable::SelectableClientPolicy::Scope.new(self, G5Updatable::Client).resolve
    end

    def clients
      G5Updatable::ClientPolicy::Scope.new(self, G5Updatable::Client).resolve
    end

    def locations
      G5Updatable::LocationPolicy::Scope.new(self, G5Updatable::Location).resolve
    end

    private
    def add_scoped_role(role)
      the_class = Object.const_get(role.type)
      resource = the_class.where(urn: role.urn).first
      add_role(role.name, resource) if resource.present?
    rescue => e
      Rails.logger.error(e)
    end
  end
end
