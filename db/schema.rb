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

ActiveRecord::Schema.define(version: 2021_02_03_122653) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.string "work_overtime"
    t.string "overtime_instructor"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.boolean "superior"
    t.datetime "designated_work_start_time"
    t.datetime "designated_work_finish_time"
    t.integer "employee_id"
    t.string "card_id"
    t.datetime "basic_work_time", default: "2021-02-02 23:00:00"
    t.datetime "work_start_time", default: "2021-02-03 00:00:00"
    t.datetime "work_finish_time", default: "2021-02-03 09:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "attendances", "users"
end
