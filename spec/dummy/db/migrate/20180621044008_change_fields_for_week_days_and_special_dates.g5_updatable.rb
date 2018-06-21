# This migration comes from g5_updatable (originally 20180213184549)
class ChangeFieldsForWeekDaysAndSpecialDates < ActiveRecord::Migration[4.2]
  def change
    remove_column :g5_updatable_week_days, :hour_description, :string if column_exists? :g5_updatable_week_days, :hour_description
    remove_column :g5_updatable_week_days, :twenty_four_hours, :boolean if column_exists? :g5_updatable_week_days, :twenty_four_hours
    remove_column :g5_updatable_special_dates, :hour_description, :string if column_exists? :g5_updatable_special_dates, :hour_description
    add_column :g5_updatable_week_days, :status, :string, default: 'none' unless column_exists? :g5_updatable_week_days, :status
    add_column :g5_updatable_special_dates, :status, :string, default: 'none' unless column_exists? :g5_updatable_special_dates, :status
  end
end
