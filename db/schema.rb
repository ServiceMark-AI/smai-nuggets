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

ActiveRecord::Schema[8.1].define(version: 2026_05_02_043612) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.datetime "approved_at"
    t.bigint "approved_by_user_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "paused_at"
    t.bigint "paused_by_user_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_user_id"], name: "index_campaigns_on_approved_by_user_id"
    t.index ["paused_by_user_id"], name: "index_campaigns_on_paused_by_user_id"
  end

  create_table "job_proposal_attachments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_proposal_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_user_id"
    t.index ["job_proposal_id"], name: "index_job_proposal_attachments_on_job_proposal_id"
    t.index ["uploaded_by_user_id"], name: "index_job_proposal_attachments_on_uploaded_by_user_id"
  end

  create_table "job_proposals", force: :cascade do |t|
    t.datetime "closed_at"
    t.bigint "closed_by_user_id"
    t.datetime "created_at", null: false
    t.bigint "created_by_user_id", null: false
    t.string "customer_city"
    t.string "customer_first_name"
    t.string "customer_house_number"
    t.string "customer_last_name"
    t.string "customer_state"
    t.string "customer_street"
    t.string "customer_title"
    t.string "customer_zip"
    t.string "internal_reference"
    t.text "job_description"
    t.bigint "job_type_id"
    t.jsonb "last_reply"
    t.text "loss_notes"
    t.string "loss_reason"
    t.bigint "organization_id", null: false
    t.bigint "owner_id", null: false
    t.string "pipeline_stage"
    t.decimal "proposal_value", precision: 12, scale: 2
    t.string "scenario_key"
    t.integer "status", default: 0, null: false
    t.string "status_details"
    t.string "status_overlay"
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["closed_by_user_id"], name: "index_job_proposals_on_closed_by_user_id"
    t.index ["created_by_user_id"], name: "index_job_proposals_on_created_by_user_id"
    t.index ["job_type_id"], name: "index_job_proposals_on_job_type_id"
    t.index ["organization_id"], name: "index_job_proposals_on_organization_id"
    t.index ["owner_id"], name: "index_job_proposals_on_owner_id"
    t.index ["tenant_id"], name: "index_job_proposals_on_tenant_id"
  end

  create_table "job_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_job_types_on_tenant_id"
  end

  create_table "organizational_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id", "user_id"], name: "index_organizational_members_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_organizational_members_on_organization_id"
    t.index ["user_id"], name: "index_organizational_members_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
    t.index ["tenant_id"], name: "index_organizations_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.boolean "is_admin", default: false, null: false
    t.boolean "is_pending", default: true, null: false
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "campaigns", "users", column: "approved_by_user_id"
  add_foreign_key "campaigns", "users", column: "paused_by_user_id"
  add_foreign_key "job_proposal_attachments", "job_proposals"
  add_foreign_key "job_proposal_attachments", "users", column: "uploaded_by_user_id"
  add_foreign_key "job_proposals", "job_types"
  add_foreign_key "job_proposals", "organizations"
  add_foreign_key "job_proposals", "tenants"
  add_foreign_key "job_proposals", "users", column: "closed_by_user_id"
  add_foreign_key "job_proposals", "users", column: "created_by_user_id"
  add_foreign_key "job_proposals", "users", column: "owner_id"
  add_foreign_key "job_types", "tenants"
  add_foreign_key "organizational_members", "organizations"
  add_foreign_key "organizational_members", "users"
  add_foreign_key "organizations", "organizations", column: "parent_id"
  add_foreign_key "organizations", "tenants"
  add_foreign_key "users", "tenants"
end
