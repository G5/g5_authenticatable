# frozen_string_literal: true

class AddG5AuthenticatableUsersContactInfo < ActiveRecord::Migration<%= migration_version %>
  def change
    change_table(:g5_authenticatable_users) do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :title
      t.string :organization_name
    end
  end
end
