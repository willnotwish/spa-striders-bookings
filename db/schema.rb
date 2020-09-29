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

ActiveRecord::Schema.define(version: 2020_09_25_184208) do

  create_table "ballot_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "ballot_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "booking_id"
    t.index ["ballot_id"], name: "index_ballot_entries_on_ballot_id"
    t.index ["booking_id"], name: "index_ballot_entries_on_booking_id"
    t.index ["user_id"], name: "index_ballot_entries_on_user_id"
  end

  create_table "ballots", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.integer "size"
    t.timestamp "opens_at"
    t.timestamp "closes_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "aasm_state"
    t.text "rules"
    t.index ["event_id"], name: "index_ballots_on_event_id"
  end

  create_table "bookings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "user_id", null: false
    t.integer "aasm_state"
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.timestamp "locked_at"
    t.bigint "locked_by_id"
    t.timestamp "honoured_at"
    t.bigint "honoured_by_id"
    t.bigint "made_by_id"
    t.timestamp "expires_at"
    t.index ["event_id"], name: "index_bookings_on_event_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "bookings_transitions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.string "from_state"
    t.string "to_state"
    t.string "source_type"
    t.bigint "source_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["booking_id"], name: "index_bookings_transitions_on_booking_id"
    t.index ["source_type", "source_id"], name: "index_bookings_transitions_on_source_type_and_source_id"
  end

  create_table "contact_numbers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "phone"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_contact_numbers_on_user_id"
  end

  create_table "events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.timestamp "starts_at"
    t.integer "capacity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "aasm_state"
    t.bigint "published_by"
    t.timestamp "published_at"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.bigint "members_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status"
    t.timestamp "guest_period_started_at"
    t.boolean "admin"
    t.timestamp "accepted_terms_at"
    t.index ["members_user_id"], name: "index_users_on_members_user_id", unique: true
  end

  create_table "waiting_list_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "waiting_list_id", null: false
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_waiting_list_entries_on_user_id"
    t.index ["waiting_list_id"], name: "index_waiting_list_entries_on_waiting_list_id"
  end

  create_table "waiting_lists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.integer "size"
    t.integer "aasm_state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_waiting_lists_on_event_id"
  end

  add_foreign_key "ballot_entries", "ballots"
  add_foreign_key "ballot_entries", "users"
  add_foreign_key "ballots", "events"
  add_foreign_key "bookings", "events"
  add_foreign_key "bookings", "users"
  add_foreign_key "bookings_transitions", "bookings"
  add_foreign_key "contact_numbers", "users"
  add_foreign_key "waiting_list_entries", "users"
  add_foreign_key "waiting_list_entries", "waiting_lists"
  add_foreign_key "waiting_lists", "events"
end
