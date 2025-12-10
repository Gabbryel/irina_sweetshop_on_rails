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

ActiveRecord::Schema[7.0].define(version: 2025_12_10_124000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cakemodels", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "slug"
    t.bigint "design_id"
    t.index ["category_id"], name: "index_cakemodels_on_category_id"
    t.index ["design_id"], name: "index_cakemodels_on_design_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "guest_token"
    t.string "status", default: "no_status", null: false
    t.string "email"
    t.string "stripe_checkout_session_id"
    t.string "stripe_payment_intent_id"
    t.string "customer_full_name"
    t.string "customer_phone"
    t.text "delivery_address"
    t.text "customer_notes"
    t.text "admin_notes"
    t.datetime "fulfilled_at"
    t.datetime "cancelled_at"
    t.string "county"
    t.date "delivery_date"
    t.string "method_of_delivery"
    t.boolean "guest_no_email", default: false, null: false
    t.index ["guest_no_email"], name: "index_carts_on_guest_no_email"
    t.index ["guest_token"], name: "index_carts_on_guest_token", unique: true
    t.index ["status"], name: "index_carts_on_status"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_recipe"
    t.boolean "has_models"
    t.string "slug"
    t.string "description", default: " "
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "delivery_block_dates", force: :cascade do |t|
    t.date "blocked_on", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocked_on"], name: "index_delivery_block_dates_on_blocked_on", unique: true
  end

  create_table "designs", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_designs_on_category_id"
  end

  create_table "extras", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.string "name", null: false
    t.integer "price_cents", default: 0, null: false
    t.boolean "available", default: true, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "position"], name: "index_extras_on_recipe_id_and_position"
    t.index ["recipe_id"], name: "index_extras_on_recipe_id"
  end

  create_table "features", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_extras", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "extra_id"
    t.string "name", null: false
    t.integer "price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["extra_id"], name: "index_item_extras_on_extra_id"
    t.index ["item_id"], name: "index_item_extras_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "cart_id", null: false
    t.string "name"
    t.float "quantity"
    t.string "kg_buc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.bigint "recipe_id"
    t.index ["cart_id"], name: "index_items_on_cart_id"
    t.index ["recipe_id"], name: "index_items_on_recipe_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "model_components", force: :cascade do |t|
    t.float "weight"
    t.bigint "cakemodel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "recipe_id"
    t.index ["cakemodel_id"], name: "index_model_components_on_cakemodel_id"
    t.index ["recipe_id"], name: "index_model_components_on_recipe_id"
  end

  create_table "model_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cakemodel_id"
    t.index ["cakemodel_id"], name: "index_model_images_on_cakemodel_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "kg_buc"
    t.boolean "favored", default: false
    t.boolean "publish", default: false
    t.string "slug"
    t.boolean "vegan"
    t.float "energetic_value"
    t.float "fats"
    t.float "fatty_acids"
    t.float "carbohydrates"
    t.float "sugars"
    t.float "proteins"
    t.float "salt"
    t.float "weight", default: 0.0
    t.string "ingredients", default: "---"
    t.integer "position", default: 9
    t.boolean "online_order", default: false, null: false
    t.decimal "minimal_order", precision: 5, scale: 2
    t.boolean "sell_by_piece", default: false, null: false
    t.integer "online_selling_price_cents", default: 0, null: false
    t.string "sold_by", default: "kg", null: false
    t.decimal "online_selling_weight", precision: 6, scale: 2
    t.text "story"
    t.integer "disable_delivery_for_days", default: 0, null: false
    t.boolean "has_extras", default: false, null: false
    t.boolean "only_pickup", default: false, null: false
    t.index ["category_id"], name: "index_recipes_on_category_id"
    t.index ["only_pickup"], name: "index_recipes_on_only_pickup"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "rating"
    t.text "content"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reviewable_type"
    t.bigint "reviewable_id"
    t.boolean "approved", default: false
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable_type_and_reviewable_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cakemodels", "categories"
  add_foreign_key "cakemodels", "designs"
  add_foreign_key "carts", "users"
  add_foreign_key "designs", "categories"
  add_foreign_key "extras", "recipes"
  add_foreign_key "item_extras", "extras"
  add_foreign_key "item_extras", "items"
  add_foreign_key "items", "carts"
  add_foreign_key "items", "recipes"
  add_foreign_key "items", "users"
  add_foreign_key "model_components", "cakemodels"
  add_foreign_key "model_components", "recipes"
  add_foreign_key "model_images", "cakemodels"
  add_foreign_key "recipes", "categories"
  add_foreign_key "reviews", "users"
end
