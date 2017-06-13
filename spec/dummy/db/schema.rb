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

ActiveRecord::Schema.define(version: 20170613201436) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "g5_authenticatable_roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_g5_authenticatable_roles_on_name_and_resource"
    t.index ["name"], name: "index_g5_authenticatable_roles_on_name"
  end

  create_table "g5_authenticatable_users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "provider", default: "g5", null: false
    t.string "uid", null: false
    t.string "g5_access_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "title"
    t.string "organization_name"
    t.index ["email"], name: "index_g5_authenticatable_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_g5_authenticatable_users_on_provider_and_uid", unique: true
  end

  create_table "g5_authenticatable_users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_g5_authenticatable_users_roles_on_user_id_and_role_id"
  end

  create_table "g5_updatable_clients", id: :serial, force: :cascade do |t|
    t.string "uid"
    t.string "urn"
    t.json "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.index ["name"], name: "index_g5_updatable_clients_on_name"
    t.index ["uid"], name: "index_g5_updatable_clients_on_uid"
    t.index ["urn"], name: "index_g5_updatable_clients_on_urn", unique: true
  end

  create_table "g5_updatable_hub_amenities", id: :serial, force: :cascade do |t|
    t.integer "external_id"
    t.string "name"
    t.string "icon"
    t.datetime "external_updated_at"
    t.datetime "external_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["external_id"], name: "index_g5_updatable_hub_amenities_on_external_id", unique: true
  end

  create_table "g5_updatable_hub_amenities_locations", id: :serial, force: :cascade do |t|
    t.integer "g5_updatable_hub_amenity_id"
    t.integer "g5_updatable_location_id"
    t.index ["g5_updatable_hub_amenity_id"], name: "updatable_amenities_loc_amen_id"
    t.index ["g5_updatable_location_id"], name: "updatable_amenities_loc_loc_id"
  end

  create_table "g5_updatable_locations", id: :serial, force: :cascade do |t|
    t.string "uid"
    t.string "urn"
    t.string "client_uid"
    t.json "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.string "flat_amenity_names"
    t.string "client_urn"
    t.index ["client_urn"], name: "index_g5_updatable_locations_on_client_urn"
    t.index ["latitude"], name: "index_g5_updatable_locations_on_latitude"
    t.index ["longitude"], name: "index_g5_updatable_locations_on_longitude"
    t.index ["name"], name: "index_g5_updatable_locations_on_name"
    t.index ["uid"], name: "index_g5_updatable_locations_on_uid"
    t.index ["urn"], name: "index_g5_updatable_locations_on_urn", unique: true
  end

  create_table "g5_updatable_points_of_interest", id: :serial, force: :cascade do |t|
    t.integer "g5_updatable_location_id"
    t.string "place_id"
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "location_type"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["g5_updatable_location_id"], name: "index_g5_updatable_poi_location_id"
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
