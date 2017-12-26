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

ActiveRecord::Schema.define(version: 20171212203913) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "faqs", force: :cascade do |t|
    t.string "question"
    t.bigint "manager_id"
    t.string "status_ap"
    t.index ["manager_id"], name: "index_faqs_on_manager_id"
  end

  create_table "managers", force: :cascade do |t|
    t.string "name"
    t.string "mail"
    t.string "user_id"
    t.string "job_title"
    t.string "department"
    t.string "phone_number"
    t.string "admin"
    t.string "source"
    t.string "manager_email"
    t.string "last_activity"
  end

  add_foreign_key "faqs", "managers"
end
