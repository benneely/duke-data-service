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

ActiveRecord::Schema.define(version: 20150811181219) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "auth_roles", force: :cascade do |t|
    t.string   "text_id"
    t.string   "name"
    t.string   "description"
    t.jsonb    "permissions"
    t.jsonb    "contexts"
    t.boolean  "is_deprecated"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "auth_roles", ["contexts"], name: "index_auth_roles_on_contexts", using: :gin
  add_index "auth_roles", ["permissions"], name: "index_auth_roles_on_permissions", using: :gin

  create_table "authentication_services", force: :cascade do |t|
    t.string   "uuid"
    t.string   "base_uri"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chunks", force: :cascade do |t|
    t.uuid     "upload_id"
    t.integer  "number"
    t.integer  "size"
    t.string   "fingerprint_value"
    t.string   "fingerprint_algorithm"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "memberships", id: false, force: :cascade do |t|
    t.string   "id",         null: false
    t.string   "user_id"
    t.string   "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "memberships", ["id"], name: "index_memberships_on_id", unique: true, using: :btree

  create_table "project_permissions", force: :cascade do |t|
    t.string   "project_id"
    t.string   "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "auth_role_id"
  end

  create_table "projects", id: false, force: :cascade do |t|
    t.string   "id",          null: false
    t.string   "name"
    t.string   "description"
    t.string   "creator_id"
    t.string   "etag"
    t.boolean  "is_deleted"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "projects", ["id"], name: "index_projects_on_id", unique: true, using: :btree

  create_table "storage_folders", force: :cascade do |t|
    t.string   "project_id"
    t.string   "name"
    t.text     "description"
    t.string   "storage_service_uuid"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "storage_providers", force: :cascade do |t|
    t.string   "name"
    t.string   "url_root"
    t.string   "provider_version"
    t.string   "auth_uri"
    t.string   "service_user"
    t.string   "service_pass"
    t.string   "primary_key"
    t.string   "secondary_key"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "uploads", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "project_id"
    t.string   "name"
    t.string   "content_type"
    t.integer  "size"
    t.string   "fingerprint_value"
    t.string   "fingerprint_algorithm"
    t.integer  "storage_provider_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "user_authentication_services", force: :cascade do |t|
    t.string   "user_id"
    t.integer  "authentication_service_id"
    t.string   "uid"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string   "id",            null: false
    t.string   "etag"
    t.string   "email"
    t.string   "display_name"
    t.jsonb    "auth_role_ids"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "users", ["id"], name: "index_users_on_id", unique: true, using: :btree

end