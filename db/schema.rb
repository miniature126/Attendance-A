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

ActiveRecord::Schema.define(version: 20201211235359) do

  create_table "approvals", force: :cascade do |t|
    t.integer "applied_approval_superior"
    t.integer "approval_superior_confirmation"
    t.boolean "approval_superior_reflection"
    t.date "applied_month"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "b_applied_approval_superior"
    t.integer "b_approval_superior_confirmation"
    t.boolean "approval_flag", default: false
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "finish_overwork"
    t.boolean "next_day", default: false
    t.string "work_contents"
    t.integer "overwork_confirmation"
    t.integer "applied_overwork"
    t.boolean "overwork_reflection"
    t.integer "applied_attendances_change"
    t.integer "change_attendances_confirmation"
    t.boolean "change_attendances_reflection"
    t.datetime "started_at_before_change"
    t.datetime "finished_at_before_change"
    t.boolean "log_flag"
    t.boolean "overwork_flag", default: false
    t.boolean "one_month_flag", default: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.integer "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "corrections", force: :cascade do |t|
    t.date "date"
    t.datetime "before_attendance_time"
    t.datetime "before_leaving_time"
    t.datetime "attendance_time"
    t.datetime "leaving_time"
    t.integer "instructor"
    t.date "approval_date"
    t.integer "attendance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_id"], name: "index_corrections_on_attendance_id", unique: true
  end

  create_table "histories", force: :cascade do |t|
    t.datetime "b_finish_overwork"
    t.boolean "b_next_day"
    t.string "b_work_contents"
    t.integer "b_applied_overwork"
    t.integer "b_overwork_confirmation"
    t.integer "attendance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "b_started_at"
    t.datetime "b_finished_at"
    t.string "b_note"
    t.integer "b_applied_attendances_change"
    t.integer "b_change_attendances_confirmation"
    t.index ["attendance_id"], name: "index_histories_on_attendance_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2020-12-22 08:00:00"
    t.boolean "superior", default: false
    t.datetime "designated_work_start_time", default: "2020-12-22 09:00:00"
    t.datetime "designated_work_end_time", default: "2020-12-22 18:00:00"
    t.integer "employee_number"
    t.string "uid"
    t.boolean "started_at_flag", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
