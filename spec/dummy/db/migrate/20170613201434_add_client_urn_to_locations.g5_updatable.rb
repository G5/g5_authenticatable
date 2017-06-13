# This migration comes from g5_updatable (originally 20161209070749)
class AddClientUrnToLocations < ActiveRecord::Migration[4.2]
  def change
    add_column :g5_updatable_locations, :client_urn, :string
    add_index :g5_updatable_locations, :client_urn
  end
end
