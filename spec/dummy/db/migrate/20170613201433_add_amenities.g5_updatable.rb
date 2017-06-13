# This migration comes from g5_updatable (originally 20161122070749)
class AddAmenities < ActiveRecord::Migration[4.2]
  def change
    create_table :g5_updatable_hub_amenities do |t|
      t.integer :external_id
      t.string :name
      t.string :icon
      t.timestamp :external_updated_at
      t.timestamp :external_created_at
      t.timestamps
    end

    add_index :g5_updatable_hub_amenities, :external_id, unique: true

    create_table :g5_updatable_hub_amenities_locations do |t|
      t.belongs_to :g5_updatable_hub_amenity
      t.belongs_to :g5_updatable_location
    end

    add_index :g5_updatable_hub_amenities_locations, :g5_updatable_hub_amenity_id, name: 'updatable_amenities_loc_amen_id'
    add_index :g5_updatable_hub_amenities_locations, :g5_updatable_location_id, name: 'updatable_amenities_loc_loc_id'

    # we need this for queries that require a location to have ALL amenities in a list
    add_column :g5_updatable_locations, :flat_amenity_names, :string
  end
end
