# This migration comes from g5_updatable (originally 20170720000000)
class AddDisplayNameToLocations < ActiveRecord::Migration[4.2]
  # indexes were not made to enforce uniqueness
  def change
    add_column :g5_updatable_locations, :display_name, :string
  end
end
