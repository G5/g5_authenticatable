# This migration comes from g5_updatable (originally 20170804184206)
class AddDetailsToPointsOfInterest < ActiveRecord::Migration[4.2]
  def change
    add_column :g5_updatable_points_of_interest, :phone_number, :string unless column_exists? :g5_updatable_points_of_interest, :phone_number
    add_column :g5_updatable_points_of_interest, :website, :string unless column_exists? :g5_updatable_points_of_interest, :website
    add_column :g5_updatable_points_of_interest, :google_map_url, :string unless column_exists? :g5_updatable_points_of_interest, :google_map_url
  end
end
