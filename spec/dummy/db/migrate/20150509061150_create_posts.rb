# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[4.2]
  def change
    create_table :posts do |t|
      t.integer :author_id
      t.string :content
      t.timestamps null: false
    end
  end
end
