# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_10_014602) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "exchanges", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "item_type_constructors", force: :cascade do |t|
    t.string "item_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "item_variant_constructors", force: :cascade do |t|
    t.text "effects", default: [], array: true
    t.text "rarities", default: [], array: true
    t.integer "power", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.string "item_type"
    t.string "rarity"
    t.string "description"
    t.integer "power"
    t.integer "worth"
    t.integer "listed_price"
    t.boolean "listed"
    t.boolean "equipped"
    t.bigint "trader_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "rift_id"
    t.bigint "exchange_id"
    t.index ["exchange_id"], name: "index_items_on_exchange_id"
    t.index ["rift_id"], name: "index_items_on_rift_id"
    t.index ["trader_id"], name: "index_items_on_trader_id"
  end

  create_table "rifts", force: :cascade do |t|
    t.string "name"
    t.integer "credits"
    t.bigint "trader_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trader_id"], name: "index_rifts_on_trader_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "traders", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "credits"
    t.integer "highest_rift_level"
    t.integer "rifts_closed"
    t.integer "items_traded"
    t.boolean "claimed_daily"
    t.datetime "refresh_time"
    t.datetime "current_time"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_traders_on_email", unique: true
    t.index ["reset_password_token"], name: "index_traders_on_reset_password_token", unique: true
    t.index ["username"], name: "index_traders_on_username", unique: true
  end

  create_table "traders_roles", id: false, force: :cascade do |t|
    t.bigint "trader_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_traders_roles_on_role_id"
    t.index ["trader_id", "role_id"], name: "index_traders_roles_on_trader_id_and_role_id"
    t.index ["trader_id"], name: "index_traders_roles_on_trader_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "items", "exchanges"
  add_foreign_key "items", "rifts"
  add_foreign_key "items", "traders"
  add_foreign_key "rifts", "traders"
end
