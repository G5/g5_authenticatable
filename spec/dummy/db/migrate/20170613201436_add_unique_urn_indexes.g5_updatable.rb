# This migration comes from g5_updatable (originally 20170507000000)
class AddUniqueUrnIndexes < ActiveRecord::Migration[4.2]
  # indexes were not made to enforce uniqueness
  def change
    remove_index :g5_updatable_clients, :urn
    add_index :g5_updatable_clients, :urn, unique: true
    remove_index :g5_updatable_locations, :urn
    add_index :g5_updatable_locations, :urn, unique: true

  end
end
