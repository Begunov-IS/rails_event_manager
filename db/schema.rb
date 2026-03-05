
ActiveRecord::Schema[8.1].define(version: 2026_03_04_143110) do
  enable_extension "pg_catalog.plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.datetime "checked_in_at"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_attendances_on_event_id"
    t.index ["user_id", "event_id"], name: "index_attendances_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_sponsors", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "sponsor_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "sponsor_id"], name: "index_event_sponsors_on_event_id_and_sponsor_id", unique: true
    t.index ["event_id"], name: "index_event_sponsors_on_event_id"
    t.index ["sponsor_id"], name: "index_event_sponsors_on_sponsor_id"
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
    t.bigint "venue_id"
    t.index ["category_id"], name: "index_events_on_category_id"
    t.index ["from_date"], name: "index_events_on_from_date"
    t.index ["owner_id"], name: "index_events_on_owner_id"
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "message", null: false
    t.string "notification_type", null: false
    t.boolean "read", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["read"], name: "index_notifications_on_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "review_text", null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.integer "rating", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_reviews_on_event_id"
    t.index ["status"], name: "index_reviews_on_status"
    t.index ["user_id", "event_id"], name: "index_reviews_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "sponsors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.datetime "updated_at", null: false
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

  create_table "venues", force: :cascade do |t|
    t.string "address", null: false
    t.integer "capacity"
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_venues_on_city"
  end

  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "users"
  add_foreign_key "event_sponsors", "events"
  add_foreign_key "event_sponsors", "sponsors"
  add_foreign_key "events", "categories"
  add_foreign_key "events", "users", column: "owner_id"
  add_foreign_key "events", "venues"
  add_foreign_key "notifications", "users"
  add_foreign_key "reviews", "events"
  add_foreign_key "reviews", "users"
  add_foreign_key "tickets", "events"
  add_foreign_key "tickets", "users"
end
