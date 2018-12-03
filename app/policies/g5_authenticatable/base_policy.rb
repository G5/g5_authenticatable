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

    def admin?
      user.present? && user.has_role?(:admin)
    end

    def editor?
      user.present? && user.has_role?(:editor)
    end

    def viewer?
      user.present? && user.has_role?(:viewer)
    end

    def has_global_role?
      ActiveSupport::Deprecation.warn <<-DEPRECATION.strip_heredoc
        [G5Authenticatable] the `has_global_role?` method is deprecated and
        will be removed. Use `global_role?` instead.
      DEPRECATION
      global_role?
    end

    def global_role?
      user.roles.global.exists?
    end
  end
end
