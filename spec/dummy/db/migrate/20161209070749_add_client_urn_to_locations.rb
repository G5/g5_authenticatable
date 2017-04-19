class AddClientUrnToLocations < ActiveRecord::Migration
  def change
    add_column :g5_updatable_locations, :client_urn, :string
    add_index :g5_updatable_locations, :client_urn
  end
end
