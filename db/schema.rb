# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090521182649) do

  create_table "catalog_titles", :force => true do |t|
    t.string   "netflix_url"
    t.decimal  "average_rating", :precision => 2, :scale => 1, :default => 0.0
    t.string   "web_page"
    t.integer  "release_year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "runtime"
    t.boolean  "validated_url"
    t.string   "title"
    t.string   "sortable_title"
  end

  add_index "catalog_titles", ["netflix_url"], :name => "index_catalog_titles_on_netflix_url", :unique => true

  create_table "ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "catalog_title_id"
    t.integer  "user_rating"
    t.decimal  "predicted_rating", :precision => 2, :scale => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["user_id", "catalog_title_id"], :name => "join_ids", :unique => true

  create_table "users", :force => true do |t|
    t.string   "netflix_id"
    t.string   "oauth_token"
    t.string   "oauth_token_secret"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "next_offset",        :default => 0
    t.integer  "next_ct_id",         :default => 0
    t.integer  "ratings_count",      :default => 0
  end

  add_index "users", ["netflix_id"], :name => "index_users_on_netflix_id", :unique => true

end
