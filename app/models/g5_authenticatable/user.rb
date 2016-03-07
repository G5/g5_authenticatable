module G5Authenticatable
  class User < ActiveRecord::Base
    devise :g5_authenticatable, :trackable, :timeoutable
    rolify role_cname: 'G5Authenticatable::Role',
           role_join_table_name: :g5_authenticatable_users_roles

    validates :email, presence: true, uniqueness: true
    validates_uniqueness_of :uid, scope: :provider

    GLOBAL_ROLE = 'GLOBAL'

    def self.new_with_session(params, session)
      user = super(params, session)
      auth_data = session['omniauth.auth']

      if auth_data
        user.assign_attributes(extended_auth_attributes(auth_data))
        user.update_roles_from_auth(auth_data)
      end
      user
    end

    def self.find_and_update_for_g5_oauth(auth_data)
      user = super(auth_data)
      if user
        user.update_attributes(extended_auth_attributes(auth_data))
        user.update_roles_from_auth(auth_data)
      end

      user
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

    def self.extended_auth_attributes(auth_data)
      h = {
        first_name: auth_data.info.first_name,
        last_name: auth_data.info.last_name,
        phone_number: auth_data.info.phone,
        title: auth_data.extra.title,
        organization_name: auth_data.extra.organization_name
      }
      auth_data.uid.present? ? h.merge!(uid: auth_data.uid) : h
    end

    def add_scoped_role(role)
      the_class = Object.const_get(role.type)
      resource = the_class.where(urn: role.urn).first
      add_role(role.name, resource) if resource.present?
    rescue => e
      Rails.logger.error(e)
    end
  end
end
