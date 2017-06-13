# This migration comes from g5_updatable (originally 20151103043916)
class AddLatitudeAndLongitudeToLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :g5_updatable_locations, :latitude, :float
    add_column :g5_updatable_locations, :longitude, :float
  end
end
