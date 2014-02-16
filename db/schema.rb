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

ActiveRecord::Schema.define(version: 20140216194813) do

  create_table "matches", force: true do |t|
    t.datetime "start",      null: false
    t.string   "map",        null: false
    t.string   "t1p1"
    t.string   "t1p2"
    t.string   "t1p3"
    t.string   "t1p4"
    t.string   "t1p5"
    t.string   "t2p1"
    t.string   "t2p2"
    t.string   "t2p3"
    t.string   "t2p4"
    t.string   "t2p5"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matches", ["map"], name: "index_matches_on_map"

  create_table "rounds", force: true do |t|
    t.datetime "start",                       null: false
    t.datetime "end",                         null: false
    t.integer  "match_id"
    t.integer  "round",                       null: false
    t.integer  "t_wins",          default: 0, null: false
    t.integer  "ct_wins",         default: 0, null: false
    t.integer  "all_ct_killed",   default: 0, null: false
    t.integer  "all_t_killed",    default: 0, null: false
    t.integer  "hostage_reached", default: 0, null: false
    t.integer  "hostage_rescued", default: 0, null: false
    t.integer  "bomb_planted",    default: 0, null: false
    t.integer  "bomb_detonated",  default: 0, null: false
    t.integer  "bomb_defused",    default: 0, null: false
    t.integer  "time_ran_out",    default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rounds", ["match_id", "round"], name: "index_rounds_on_match_id_and_round", unique: true
  add_index "rounds", ["match_id"], name: "index_rounds_on_match_id"

end
