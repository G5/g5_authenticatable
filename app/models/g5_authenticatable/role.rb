# frozen_string_literal: true

module G5Authenticatable
  # A user role (e.g. admin, viewer), optionally scoped to a client or location
  class Role < ActiveRecord::Base
    has_and_belongs_to_many :users, join_table: :g5_authenticatable_users_roles

    if Rails::VERSION::MAJOR >= 5
      belongs_to :resource, polymorphic: true, optional: true
    else
      belongs_to :resource, polymorphic: true
    end

    scopify
  end
end
