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

ActiveRecord::Schema.define(version: 20150408045536) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.string   "image_id"
    t.string   "author_id"
    t.integer  "timestamp",  limit: 8
    t.text     "plain_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reply_to",   limit: 8
    t.text     "enc_text"
  end

  create_table "contacts", force: true do |t|
    t.string   "public_id"
    t.string   "contact_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", force: true do |t|
    t.string   "public_id_src"
    t.string   "public_id_dest"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_key"
  end

  create_table "images", force: true do |t|
    t.string  "image_id"
    t.string  "author_id"
    t.string  "url_original"
    t.string  "url_medium"
    t.string  "url_small"
    t.float   "aspect_ratio"
    t.integer "timestamp",     limit: 8
    t.integer "status"
    t.string  "title"
    t.integer "storage",                 default: 0
    t.string  "path_original"
    t.string  "path_medium"
    t.string  "path_small"
    t.string  "likes",                   default: [], array: true
    t.text    "local_uri"
  end

  create_table "users", force: true do |t|
    t.string   "private_id"
    t.string   "contact_key"
    t.string   "plain_profile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "pushid"
    t.integer  "smscode"
    t.integer  "status"
    t.text     "enc_profile"
    t.string   "h_contact_key"
    t.integer  "utype"
  end

end
