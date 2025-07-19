# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_07_19_202345) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "admins", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "email"
    t.string "name", null: false
    t.string "last_name", null: false
    t.integer "role", default: 0
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.datetime "deleted_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_admins_on_uid_and_provider", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "name", null: false
    t.string "api_id", null: false
    t.string "api_key", null: false
    t.bigint "role", default: 0
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_api_keys_on_tenant_id"
  end

  create_table "bots", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.text "custom_instructions"
    t.string "whatsapp_phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.text "user_instructions"
    t.index ["tenant_id"], name: "index_bots_on_tenant_id"
  end

  create_table "completions", force: :cascade do |t|
    t.bigint "bot_id", null: false
    t.integer "status", default: 0
    t.string "prompt"
    t.text "full_prompt"
    t.json "context"
    t.string "response"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "conversation_id"
    t.index ["bot_id"], name: "index_completions_on_bot_id"
    t.index ["conversation_id"], name: "index_completions_on_conversation_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "tenant_id"
    t.string "name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_contacts_on_tenant_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.string "title"
    t.bigint "bot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bot_id"], name: "index_conversations_on_bot_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "contact_id"
    t.integer "status", default: 0
    t.integer "sender", default: 0
    t.integer "content_type", default: 0
    t.string "body"
    t.string "media_url"
    t.string "vonage_id"
    t.string "custom_destination"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_messages_on_contact_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.json "settings", default: {}
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "email"
    t.string "name", null: false
    t.string "last_name", null: false
    t.json "tokens"
    t.string "api_id"
    t.string "api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "tenant_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "admins", "tenants"
  add_foreign_key "bots", "tenants"
  add_foreign_key "completions", "bots"
  add_foreign_key "completions", "conversations"
  add_foreign_key "contacts", "tenants"
  add_foreign_key "conversations", "bots"
  add_foreign_key "messages", "contacts"
  add_foreign_key "users", "tenants"
end
