# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140203020903) do

  create_table "g5_authenticatable_users", :force => true do |t|
    t.string   "email",              :default => "",   :null => false
    t.string   "provider",           :default => "g5", :null => false
    t.string   "uid",                                  :null => false
    t.string   "g5_access_token"
    t.integer  "sign_in_count",      :default => 0,    :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "g5_authenticatable_users", ["email"], :name => "index_g5_authenticatable_users_on_email", :unique => true
  add_index "g5_authenticatable_users", ["provider", "uid"], :name => "index_g5_authenticatable_users_on_provider_and_uid", :unique => true

end
