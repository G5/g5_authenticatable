# frozen_string_literal: true

# This migration comes from g5_updatable (originally 20141122211945)
class RemoveIntegrationSetting < ActiveRecord::Migration[4.2]
  def change
    drop_table :g5_updatable_integration_settings
  end
end
