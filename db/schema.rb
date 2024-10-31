# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_10_31_135631) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.string "location", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_update_logs", force: :cascade do |t|
    t.text "result", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "buildings", primary_key: "bldrecnbr", force: :cascade do |t|
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.string "nick_name"
    t.string "abbreviation"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "tsv"
    t.bigint "campus_record_id"
    t.boolean "visible", default: true
    t.index ["campus_record_id"], name: "index_buildings_on_campus_record_id"
    t.index ["tsv"], name: "index_buildings_on_tsv", using: :gin
  end

  create_table "campus_records", force: :cascade do |t|
    t.integer "campus_cd"
    t.string "campus_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "floors", force: :cascade do |t|
    t.string "floor"
    t.bigint "building_bldrecnbr", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_bldrecnbr"], name: "index_floors_on_building_bldrecnbr"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "noteable_type", null: false
    t.bigint "noteable_id", null: false
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alert", default: false
    t.index ["noteable_type", "noteable_id"], name: "index_notes_on_noteable"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "omni_auth_services", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.string "access_token_secret"
    t.string "refresh_token"
    t.datetime "expires_at", precision: nil
    t.text "auth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_omni_auth_services_on_user_id"
  end

  create_table "omniauth_services", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.string "access_token_secret"
    t.string "refresh_token"
    t.datetime "expires_at", precision: nil
    t.text "auth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_omniauth_services_on_user_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "room_characteristics", force: :cascade do |t|
    t.bigint "rmrecnbr", null: false
    t.integer "chrstc"
    t.integer "chrstc_eff_status"
    t.string "chrstc_descrshort"
    t.string "chrstc_descr"
    t.string "chrstc_desc254"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chrstc", "rmrecnbr"], name: "index_room_characteristics_on_chrstc_and_rmrecnbr", unique: true
    t.index ["rmrecnbr"], name: "index_room_characteristics_on_rmrecnbr"
  end

  create_table "room_contacts", force: :cascade do |t|
    t.bigint "rmrecnbr", null: false
    t.string "rm_schd_cntct_name"
    t.string "rm_schd_email"
    t.string "rm_schd_cntct_phone"
    t.string "rm_det_url"
    t.string "rm_usage_guidlns_url"
    t.string "rm_sppt_deptid"
    t.string "rm_sppt_dept_descr"
    t.string "rm_sppt_cntct_email"
    t.string "rm_sppt_cntct_phone"
    t.string "rm_sppt_cntct_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rmrecnbr"], name: "index_room_contacts_on_rmrecnbr"
  end

  create_table "rooms", primary_key: "rmrecnbr", force: :cascade do |t|
    t.string "floor"
    t.string "room_number"
    t.string "rmtyp_description"
    t.integer "dept_id"
    t.string "dept_grp"
    t.string "dept_description"
    t.string "facility_code_heprod"
    t.integer "square_feet"
    t.integer "instructional_seating_count"
    t.text "characteristics", default: [], array: true
    t.boolean "visible"
    t.bigint "building_bldrecnbr", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "tsv"
    t.string "dept_group_description"
    t.string "building_name"
    t.bigint "campus_record_id"
    t.integer "ada_seat_count"
    t.string "nickname"
    t.index ["building_bldrecnbr"], name: "index_rooms_on_building_bldrecnbr"
    t.index ["campus_record_id"], name: "index_rooms_on_campus_record_id"
    t.index ["tsv"], name: "index_rooms_on_tsv", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar_url"
    t.string "provider"
    t.string "uid"
    t.text "mcommunity_groups", default: "", null: false
    t.string "uniqname"
    t.string "principal_name"
    t.string "display_name"
    t.string "person_affiliation"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uniqname"], name: "index_users_on_uniqname", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "buildings", "campus_records"
  add_foreign_key "floors", "buildings", column: "building_bldrecnbr", primary_key: "bldrecnbr"
  add_foreign_key "notes", "users"
  add_foreign_key "omni_auth_services", "users"
  add_foreign_key "omniauth_services", "users"
  add_foreign_key "room_characteristics", "rooms", column: "rmrecnbr", primary_key: "rmrecnbr"
  add_foreign_key "room_contacts", "rooms", column: "rmrecnbr", primary_key: "rmrecnbr"
  add_foreign_key "rooms", "buildings", column: "building_bldrecnbr", primary_key: "bldrecnbr"
  add_foreign_key "rooms", "campus_records"
end
