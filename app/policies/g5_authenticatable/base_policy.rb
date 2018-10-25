# frozen_string_literal: true

module G5Authenticatable
  # Base class for all pundit authorization policies
  # Defaults to limiting every action to super admin users
  class BasePolicy
    attr_reader :user, :record

    def initialize(user, record = nil)
      @user = user
      @record = record
    end

    def index?
      super_admin?
    end

    def show?
      scope.where(id: record.id).exists?
    end

    def create?
      super_admin?
    end

    def new?
      create?
    end

    def update?
      super_admin?
    end

    def edit?
      update?
    end

    def destroy?
      super_admin?
    end

    def scope
      Pundit.policy_scope!(user, record.class)
    end

    # Base class for all authorization scopes
    class BaseScope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        if user.has_role?(:super_admin)
          scope.all
        else
          scope.none
        end
      end

      def global_role?
        G5Authenticatable::BasePolicy.new(user, nil).global_role?
      end

      alias has_global_role? global_role?
    end

    def super_admin?
      user.present? && user.has_role?(:super_admin)
    end

    def check_for_role(role_name,global_scope=false)
      if user.present?
        query = user.roles.where(name: role_name)
        query = query.where(resource_type: nil) if global_scope
        return query.exists?
      else
        return false
      end
    end

    def admin?(global_scope=false)
      check_for_role(:admin,global_scope)
    end

    def editor?(global_scope=false)
      check_for_role(:editor,global_scope)
    end

    def viewer?(global_scope=false)
      check_for_role(:viewer,global_scope)
    end

    def has_global_role?
      ActiveSupport::Deprecation.warn <<-DEPRECATION.strip_heredoc
        [G5Authenticatable] the `has_global_role?` method is deprecated and
        will be removed. Use `global_role?` instead.
      DEPRECATION
      global_role?
    end

    def global_role?
      super_admin? || admin?(true) || editor?(true) || viewer?(true)
    end
  end
end
