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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161209070749) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "g5_authenticatable_roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "g5_authenticatable_roles", ["name", "resource_type", "resource_id"], name: "index_g5_authenticatable_roles_on_name_and_resource", using: :btree
  add_index "g5_authenticatable_roles", ["name"], name: "index_g5_authenticatable_roles_on_name", using: :btree

  create_table "g5_authenticatable_users", force: :cascade do |t|
    t.string   "email",              default: "",   null: false
    t.string   "provider",           default: "g5", null: false
    t.string   "uid",                               null: false
    t.string   "g5_access_token"
    t.integer  "sign_in_count",      default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "title"
    t.string   "organization_name"
  end

  add_index "g5_authenticatable_users", ["email"], name: "index_g5_authenticatable_users_on_email", unique: true, using: :btree
  add_index "g5_authenticatable_users", ["provider", "uid"], name: "index_g5_authenticatable_users_on_provider_and_uid", unique: true, using: :btree

  create_table "g5_authenticatable_users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "g5_authenticatable_users_roles", ["user_id", "role_id"], name: "index_g5_authenticatable_users_roles_on_user_id_and_role_id", using: :btree

  create_table "g5_updatable_clients", force: :cascade do |t|
    t.string   "uid"
    t.string   "urn"
    t.json     "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "g5_updatable_clients", ["name"], name: "index_g5_updatable_clients_on_name", using: :btree
  add_index "g5_updatable_clients", ["uid"], name: "index_g5_updatable_clients_on_uid", using: :btree
  add_index "g5_updatable_clients", ["urn"], name: "index_g5_updatable_clients_on_urn", using: :btree

  create_table "g5_updatable_hub_amenities", force: :cascade do |t|
    t.integer  "external_id"
    t.string   "name"
    t.string   "icon"
    t.datetime "external_updated_at"
    t.datetime "external_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "g5_updatable_hub_amenities", ["external_id"], name: "index_g5_updatable_hub_amenities_on_external_id", unique: true, using: :btree

  create_table "g5_updatable_hub_amenities_locations", force: :cascade do |t|
    t.integer "g5_updatable_hub_amenity_id"
    t.integer "g5_updatable_location_id"
  end

  add_index "g5_updatable_hub_amenities_locations", ["g5_updatable_hub_amenity_id"], name: "updatable_amenities_loc_amen_id", using: :btree
  add_index "g5_updatable_hub_amenities_locations", ["g5_updatable_location_id"], name: "updatable_amenities_loc_loc_id", using: :btree

  create_table "g5_updatable_locations", force: :cascade do |t|
    t.string   "uid"
    t.string   "urn"
    t.string   "client_uid"
    t.json     "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "flat_amenity_names"
    t.string   "client_urn"
  end

  add_index "g5_updatable_locations", ["client_urn"], name: "index_g5_updatable_locations_on_client_urn", using: :btree
  add_index "g5_updatable_locations", ["name"], name: "index_g5_updatable_locations_on_name", using: :btree
  add_index "g5_updatable_locations", ["uid"], name: "index_g5_updatable_locations_on_uid", using: :btree
  add_index "g5_updatable_locations", ["urn"], name: "index_g5_updatable_locations_on_urn", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "author_id"
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
