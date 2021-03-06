# frozen_string_literal: true

# This migration comes from g5_updatable (originally 20141211211945)
class AddNameToClientsAndLocations < ActiveRecord::Migration[4.2]
  def change
    add_column :g5_updatable_clients, :name, :string
    add_index :g5_updatable_clients, :name

    add_column :g5_updatable_locations, :name, :string
    add_index :g5_updatable_locations, :name
  end
end
