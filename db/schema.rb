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

ActiveRecord::Schema[7.0].define(version: 2026_02_09_192536) do
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

  create_table "addresses", force: :cascade do |t|
    t.bigint "user_id"
    t.string "full_name"
    t.string "phone"
    t.string "line1", null: false
    t.string "line2"
    t.string "city"
    t.string "county"
    t.string "postal_code"
    t.string "country", default: "RO", null: false
    t.string "kind", default: "shipping", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_addresses_on_kind"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "action", null: false
    t.string "auditable_type"
    t.integer "auditable_id"
    t.jsonb "change_data", default: {}
    t.string "ip_address"
    t.string "user_agent"
    t.string "request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
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
    t.datetime "paid_at", precision: nil
    t.datetime "reminder_sent_at", precision: nil
    t.datetime "payment_followups_scheduled_at", precision: nil
    t.index ["guest_no_email"], name: "index_carts_on_guest_no_email"
    t.index ["guest_token"], name: "index_carts_on_guest_token", unique: true
    t.index ["paid_at"], name: "index_carts_on_paid_at"
    t.index ["payment_followups_scheduled_at"], name: "index_carts_on_payment_followups_scheduled_at"
    t.index ["reminder_sent_at"], name: "index_carts_on_reminder_sent_at"
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

  create_table "hero_sections", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "button_text"
    t.string "button_link"
    t.string "chocolate_color"
    t.string "background_image_url"
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

  create_table "lab_batch_consumptions", force: :cascade do |t|
    t.bigint "batch_id", null: false
    t.bigint "ingredient_id", null: false
    t.integer "qty_g", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_lab_batch_consumptions_on_batch_id"
    t.index ["ingredient_id"], name: "index_lab_batch_consumptions_on_ingredient_id"
  end

  create_table "lab_batches", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "recipe_id"
    t.integer "planned_qty"
    t.integer "yield_qty"
    t.string "status", default: "planned", null: false
    t.datetime "scheduled_for"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_lab_batches_on_product_id"
    t.index ["recipe_id"], name: "index_lab_batches_on_recipe_id"
    t.index ["scheduled_for"], name: "index_lab_batches_on_scheduled_for"
    t.index ["status"], name: "index_lab_batches_on_status"
  end

  create_table "lab_cost_allocation_runs", force: :cascade do |t|
    t.date "started_on", null: false
    t.date "ended_on", null: false
    t.decimal "calibration_factor", precision: 8, scale: 4, default: "1.0", null: false
    t.string "status", default: "pending", null: false
    t.jsonb "outputs", default: {}, null: false
    t.text "notes"
    t.bigint "ran_by_id"
    t.datetime "ran_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ran_by_id"], name: "index_lab_cost_allocation_runs_on_ran_by_id"
    t.index ["started_on", "ended_on"], name: "index_lab_cost_allocation_runs_on_started_on_and_ended_on"
    t.index ["status"], name: "index_lab_cost_allocation_runs_on_status"
  end

  create_table "lab_ingredients", force: :cascade do |t|
    t.bigint "supplier_id"
    t.string "name", null: false
    t.string "unit", default: "g", null: false
    t.text "notes"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_lab_ingredients_on_active"
    t.index ["name"], name: "index_lab_ingredients_on_name"
    t.index ["supplier_id"], name: "index_lab_ingredients_on_supplier_id"
  end

  create_table "lab_inventory_moves", force: :cascade do |t|
    t.bigint "lot_id", null: false
    t.decimal "qty", precision: 12, scale: 3, null: false
    t.string "reason", null: false
    t.string "reference_type"
    t.bigint "reference_id"
    t.datetime "occurred_at", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_lab_inventory_moves_on_created_by_id"
    t.index ["lot_id"], name: "index_lab_inventory_moves_on_lot_id"
    t.index ["occurred_at"], name: "index_lab_inventory_moves_on_occurred_at"
    t.index ["reference_type", "reference_id"], name: "index_lab_inventory_moves_on_reference_type_and_reference_id"
  end

  create_table "lab_lots", force: :cascade do |t|
    t.bigint "ingredient_id", null: false
    t.bigint "supplier_id"
    t.decimal "qty", precision: 12, scale: 3, default: "0.0", null: false
    t.decimal "remaining_qty", precision: 12, scale: 3, default: "0.0", null: false
    t.string "unit", default: "g", null: false
    t.integer "cost_cents", default: 0, null: false
    t.string "currency", default: "RON", null: false
    t.datetime "received_at"
    t.date "expiry_at"
    t.string "reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expiry_at"], name: "index_lab_lots_on_expiry_at"
    t.index ["ingredient_id", "expiry_at"], name: "index_lab_lots_on_ingredient_id_and_expiry_at"
    t.index ["ingredient_id"], name: "index_lab_lots_on_ingredient_id"
    t.index ["supplier_id"], name: "index_lab_lots_on_supplier_id"
  end

  create_table "lab_payroll_imports", force: :cascade do |t|
    t.date "month", null: false
    t.string "role_name", null: false
    t.integer "total_cost_cents", default: 0, null: false
    t.string "currency", default: "RON", null: false
    t.string "source_filename"
    t.bigint "uploaded_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["month", "role_name"], name: "index_lab_payroll_imports_on_month_and_role_name"
    t.index ["uploaded_by_id"], name: "index_lab_payroll_imports_on_uploaded_by_id"
  end

  create_table "lab_recipe_lines", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "ingredient_id", null: false
    t.integer "qty_g", null: false
    t.integer "step"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_lab_recipe_lines_on_ingredient_id"
    t.index ["recipe_id", "step"], name: "index_lab_recipe_lines_on_recipe_id_and_step"
    t.index ["recipe_id"], name: "index_lab_recipe_lines_on_recipe_id"
  end

  create_table "lab_recipes", force: :cascade do |t|
    t.bigint "product_id"
    t.string "name", null: false
    t.integer "version", default: 1, null: false
    t.string "status", default: "draft", null: false
    t.text "notes"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_lab_recipes_on_created_by_id"
    t.index ["name", "version"], name: "index_lab_recipes_on_name_and_version"
    t.index ["product_id"], name: "index_lab_recipes_on_product_id"
    t.index ["status"], name: "index_lab_recipes_on_status"
  end

  create_table "lab_standard_times", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.string "station", null: false
    t.integer "step"
    t.integer "minutes", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "station"], name: "index_lab_standard_times_on_recipe_id_and_station"
    t.index ["recipe_id"], name: "index_lab_standard_times_on_recipe_id"
  end

  create_table "lab_suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.string "phone"
    t.text "notes"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_lab_suppliers_on_active"
  end

  create_table "lab_utility_readings", force: :cascade do |t|
    t.date "reading_on", null: false
    t.string "location", default: "main", null: false
    t.decimal "kwh", precision: 12, scale: 3, default: "0.0", null: false
    t.decimal "gas_m3", precision: 12, scale: 3, default: "0.0", null: false
    t.integer "price_kwh_cents", default: 0, null: false
    t.integer "price_gas_cents", default: 0, null: false
    t.string "currency", default: "RON", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reading_on", "location"], name: "index_lab_utility_readings_on_reading_on_and_location", unique: true
  end

  create_table "lab_waste_events", force: :cascade do |t|
    t.string "kind", null: false
    t.bigint "ingredient_id"
    t.bigint "batch_id"
    t.decimal "qty", precision: 12, scale: 3
    t.string "unit"
    t.integer "cost_estimated_cents", default: 0, null: false
    t.string "currency", default: "RON", null: false
    t.text "reason_text"
    t.datetime "occurred_at", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_lab_waste_events_on_batch_id"
    t.index ["created_by_id"], name: "index_lab_waste_events_on_created_by_id"
    t.index ["ingredient_id"], name: "index_lab_waste_events_on_ingredient_id"
    t.index ["kind"], name: "index_lab_waste_events_on_kind"
    t.index ["occurred_at"], name: "index_lab_waste_events_on_occurred_at"
  end

  create_table "manual_blocks", force: :cascade do |t|
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "scope", default: "global", null: false
    t.bigint "category_id"
    t.bigint "product_id"
    t.string "reason"
    t.boolean "active", default: true, null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_manual_blocks_on_active"
    t.index ["category_id"], name: "index_manual_blocks_on_category_id"
    t.index ["created_by_id"], name: "index_manual_blocks_on_created_by_id"
    t.index ["product_id"], name: "index_manual_blocks_on_product_id"
    t.index ["scope"], name: "index_manual_blocks_on_scope"
    t.index ["starts_at", "ends_at"], name: "index_manual_blocks_on_starts_at_and_ends_at"
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

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id"
    t.string "name", null: false
    t.integer "qty"
    t.integer "weight_estimated_g"
    t.boolean "final_weight_at_pickup", default: false, null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.jsonb "extras", default: {}, null: false
    t.string "design_tier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "order_overrides", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "operator_id", null: false
    t.string "override_type", null: false
    t.jsonb "changes", default: {}, null: false
    t.text "reason"
    t.datetime "created_at", null: false
    t.index ["operator_id"], name: "index_order_overrides_on_operator_id"
    t.index ["order_id"], name: "index_order_overrides_on_order_id"
    t.index ["override_type"], name: "index_order_overrides_on_override_type"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "address_id"
    t.string "status", default: "confirmed", null: false
    t.string "fulfillment_method", null: false
    t.datetime "scheduled_at"
    t.string "language", default: "ro", null: false
    t.string "email"
    t.string "customer_full_name"
    t.string "customer_phone"
    t.text "customer_notes"
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "delivery_fee_cents", default: 0, null: false
    t.integer "discount_cents", default: 0, null: false
    t.integer "total_estimated_cents", default: 0, null: false
    t.string "currency", default: "RON", null: false
    t.integer "weight_final_g"
    t.boolean "requires_operator_confirmation", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["fulfillment_method"], name: "index_orders_on_fulfillment_method"
    t.index ["scheduled_at"], name: "index_orders_on_scheduled_at"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "stripe_checkout_session_id"
    t.string "payment_intent_id"
    t.string "payment_mode", null: false
    t.string "status", default: "pending", null: false
    t.integer "paid_amount_cents", default: 0, null: false
    t.string "currency", default: "RON", null: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["payment_intent_id"], name: "index_payments_on_payment_intent_id"
    t.index ["stripe_checkout_session_id"], name: "index_payments_on_stripe_checkout_session_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "category_id"
    t.string "name", null: false
    t.string "slug", null: false
    t.string "price_type", null: false
    t.integer "base_price_cents", default: 0, null: false
    t.string "currency", default: "RON", null: false
    t.integer "standard_weight_g"
    t.boolean "immediate_delivery", default: false, null: false
    t.boolean "courier_eligible", default: false, null: false
    t.text "allergens", default: [], null: false, array: true
    t.boolean "cake_design_enabled", default: false, null: false
    t.string "design_tier_default", default: "standard", null: false
    t.string "product_type", default: "other", null: false
    t.boolean "active", default: true, null: false
    t.bigint "legacy_recipe_id"
    t.bigint "legacy_cakemodel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_products_on_active"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["courier_eligible"], name: "index_products_on_courier_eligible"
    t.index ["product_type"], name: "index_products_on_product_type"
    t.index ["slug"], name: "index_products_on_slug", unique: true
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

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "site_setting_templates", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.json "settings", default: {}
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_site_setting_templates_on_active"
    t.index ["name"], name: "index_site_setting_templates_on_name", unique: true
  end

  create_table "site_settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_site_settings_on_key", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
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

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.text "object_changes"
    t.datetime "created_at"
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "audit_logs", "users"
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
  add_foreign_key "lab_batch_consumptions", "lab_batches", column: "batch_id"
  add_foreign_key "lab_batch_consumptions", "lab_ingredients", column: "ingredient_id"
  add_foreign_key "lab_batches", "lab_recipes", column: "recipe_id"
  add_foreign_key "lab_batches", "products"
  add_foreign_key "lab_cost_allocation_runs", "users", column: "ran_by_id"
  add_foreign_key "lab_ingredients", "lab_suppliers", column: "supplier_id"
  add_foreign_key "lab_inventory_moves", "lab_lots", column: "lot_id"
  add_foreign_key "lab_inventory_moves", "users", column: "created_by_id"
  add_foreign_key "lab_lots", "lab_ingredients", column: "ingredient_id"
  add_foreign_key "lab_lots", "lab_suppliers", column: "supplier_id"
  add_foreign_key "lab_payroll_imports", "users", column: "uploaded_by_id"
  add_foreign_key "lab_recipe_lines", "lab_ingredients", column: "ingredient_id"
  add_foreign_key "lab_recipe_lines", "lab_recipes", column: "recipe_id"
  add_foreign_key "lab_recipes", "products"
  add_foreign_key "lab_recipes", "users", column: "created_by_id"
  add_foreign_key "lab_standard_times", "lab_recipes", column: "recipe_id"
  add_foreign_key "lab_waste_events", "lab_batches", column: "batch_id"
  add_foreign_key "lab_waste_events", "lab_ingredients", column: "ingredient_id"
  add_foreign_key "lab_waste_events", "users", column: "created_by_id"
  add_foreign_key "manual_blocks", "categories"
  add_foreign_key "manual_blocks", "products"
  add_foreign_key "manual_blocks", "users", column: "created_by_id"
  add_foreign_key "model_components", "cakemodels"
  add_foreign_key "model_components", "recipes"
  add_foreign_key "model_images", "cakemodels"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_overrides", "orders"
  add_foreign_key "order_overrides", "users", column: "operator_id"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "products", "categories"
  add_foreign_key "recipes", "categories"
  add_foreign_key "reviews", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
