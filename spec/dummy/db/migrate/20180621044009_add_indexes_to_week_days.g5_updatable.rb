# This migration comes from g5_updatable (originally 20180220203057)
class AddIndexesToWeekDays < ActiveRecord::Migration[4.2]
  def change
    add_index :g5_updatable_week_days, :day_of_week unless index_exists? :g5_updatable_week_days, :day_of_week
    add_index :g5_updatable_week_days, :hour_set_id unless index_exists? :g5_updatable_week_days, :hour_set_id
    add_index :g5_updatable_special_dates, :hour_set_id unless index_exists? :g5_updatable_special_dates, :hour_set_id
  end
end
