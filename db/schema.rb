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

ActiveRecord::Schema.define(version: 20180523085934) do

  create_table "results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                    null: false
    t.string   "role",                       null: false
    t.boolean  "win",        default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["user_id"], name: "index_results_on_user_id", using: :btree
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "player_cnt",                default: 0
    t.string   "special_roles"
    t.string   "wolf_roles"
    t.integer  "villager_cnt",              default: 0
    t.integer  "normal_wolf_cnt",           default: 0
    t.integer  "witch_self_save", limit: 1, default: 0, null: false
    t.integer  "win_cond",        limit: 1, default: 0, null: false
    t.string   "must_kill"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                             null: false
    t.string   "image"
    t.integer  "role",       limit: 1, default: 0, null: false
    t.string   "alias"
    t.integer  "login_type", limit: 1, default: 0, null: false
    t.string   "wx_openid"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["login_type", "name"], name: "index_users_on_login_type_and_name", unique: true, using: :btree
    t.index ["login_type", "wx_openid"], name: "index_users_on_login_type_and_wx_openid", unique: true, using: :btree
  end

end
