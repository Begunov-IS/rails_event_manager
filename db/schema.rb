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

ActiveRecord::Schema[8.1].define(version: 2026_02_15_130507) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "from_date", null: false
    t.string "location", null: false
    t.bigint "owner_id", null: false
    t.string "title", null: false
    t.datetime "to_date", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_events_on_category_id"
    t.index ["from_date"], name: "index_events_on_from_date"
    t.index ["owner_id"], name: "index_events_on_owner_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "status", default: "available", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["event_id"], name: "index_tickets_on_event_id"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "events", "categories"
  add_foreign_key "events", "users", column: "owner_id"
  add_foreign_key "tickets", "events"
  add_foreign_key "tickets", "users"
end
