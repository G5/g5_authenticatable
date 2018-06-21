# This migration comes from g5_updatable (originally 20170428000000)
class AddHourSets < ActiveRecord::Migration[4.2]
  def change
    unless table_exists? :g5_updatable_hour_sets
      create_table :g5_updatable_hour_sets do |t|
        t.belongs_to :g5_updatable_location
        t.integer  "location_id"
        t.string   "name"
        t.string   "hour_type"
        t.boolean  "is_active"
        t.string   "additional_hours_info"
        t.timestamps
      end
      add_index :g5_updatable_hour_sets, :g5_updatable_location_id, name: 'index_g5_updatable_hour_sets_location_id'
    end

    unless table_exists? :g5_updatable_week_days
      create_table :g5_updatable_week_days do |t|
        t.belongs_to :g5_updatable_location
        t.integer  "hour_set_id"
        t.integer  "day_of_week"
        t.string   "hour_description"
        t.time     "open"
        t.time     "close"
        t.boolean  "twenty_four_hours", default: false
        t.timestamps
      end
      add_index :g5_updatable_week_days, :g5_updatable_location_id, name: 'index_g5_updatable_business_days_location_id'
    end

    unless table_exists? :g5_updatable_special_dates
      create_table :g5_updatable_special_dates do |t|
        t.belongs_to :g5_updatable_location
        t.integer "hour_set_id"
        t.date    "date"
        t.string  "hour_description"
        t.time    "open"
        t.time    "close"
        t.boolean "is_regular_hours", default: false
        t.timestamps
      end
      add_index :g5_updatable_special_dates, :g5_updatable_location_id, name: 'index_g5_updatable_special_dates_location_id'
    end
  end
end