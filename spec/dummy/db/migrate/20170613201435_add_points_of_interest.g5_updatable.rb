# This migration comes from g5_updatable (originally 20170422000000)
class AddPointsOfInterest < ActiveRecord::Migration[4.2]
  def change
    create_table :g5_updatable_points_of_interest do |t|
      t.belongs_to :g5_updatable_location
      t.string   "place_id"
      t.string   "name"
      t.string   "address"
      t.string   "city"
      t.string   "state"
      t.string   "postal_code"
      t.string   "location_type"
      t.float    "latitude"
      t.float    "longitude"
      t.timestamps
    end

    add_index :g5_updatable_points_of_interest, :g5_updatable_location_id, name: 'index_g5_updatable_poi_location_id'

  end
end
