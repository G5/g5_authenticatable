# This migration comes from g5_updatable (originally 20151106070749)
class AddLatitudeLongitudeIndexesToLocation < ActiveRecord::Migration[4.2]
  def change
    add_index :g5_updatable_locations, :latitude
    add_index :g5_updatable_locations, :longitude
  end
end
