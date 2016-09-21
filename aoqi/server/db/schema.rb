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

ActiveRecord::Schema.define(version: 20130806024255) do

  create_table "attr_conflicts", force: true do |t|
    t.integer  "attack_id"
    t.integer  "defence_id"
    t.integer  "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attr_conflicts", ["attack_id"], name: "index_attr_conflicts_on_attack_id"
  add_index "attr_conflicts", ["defence_id"], name: "index_attr_conflicts_on_defence_id"

  create_table "attrs", force: true do |t|
    t.string   "name"
    t.string   "name2"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attrs", ["name"], name: "index_attrs_on_name"
  add_index "attrs", ["name2"], name: "index_attrs_on_name2"

  create_table "heros", force: true do |t|
    t.string   "name"
    t.string   "name2"
    t.text     "skill1"
    t.text     "skill2"
    t.text     "skill3"
    t.integer  "damage_sum"
    t.integer  "hp"
    t.integer  "speed"
    t.integer  "normal_damage"
    t.integer  "magical_damage"
    t.integer  "super_damage"
    t.integer  "normal_armor"
    t.integer  "magical_armor"
    t.integer  "super_armor"
    t.integer  "type_id"
    t.integer  "attr_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "heros", ["attr_id"], name: "index_heros_on_attr_id"
  add_index "heros", ["name"], name: "index_heros_on_name"
  add_index "heros", ["name2"], name: "index_heros_on_name2"
  add_index "heros", ["type_id"], name: "index_heros_on_type_id"

  create_table "types", force: true do |t|
    t.string   "name"
    t.string   "name2"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "types", ["name"], name: "index_types_on_name"
  add_index "types", ["name2"], name: "index_types_on_name2"

end
