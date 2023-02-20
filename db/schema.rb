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

ActiveRecord::Schema.define(version: 20170801122957) do

  create_table "addresses", force: :cascade do |t|
    t.integer  "owner_id",    limit: 4
    t.string   "owner_type",  limit: 255
    t.integer  "location_id", limit: 4
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "addresses", ["owner_id"], name: "index_addresses_on_owner_id", using: :btree

  create_table "article_quantities", force: :cascade do |t|
    t.integer  "article_id",   limit: 4,                                          null: false
    t.string   "part",         limit: 128
    t.string   "note",         limit: 2048
    t.decimal  "qty",                       precision: 8, scale: 3, default: 0.0, null: false
    t.decimal  "qty_sold",                  precision: 8, scale: 3, default: 0.0, null: false
    t.integer  "active",       limit: 4,                            default: 1,   null: false
    t.integer  "lock_version", limit: 4,                            default: 0
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
  end

  add_index "article_quantities", ["article_id"], name: "index_article_quantities_on_article_id", using: :btree

  create_table "articles", force: :cascade do |t|
    t.integer  "product_id",          limit: 4,                                          null: false
    t.integer  "size_id",             limit: 4
    t.integer  "color_id",            limit: 4
    t.string   "name",                limit: 2048
    t.decimal  "price",                            precision: 8, scale: 2, default: 0.0
    t.decimal  "perc_discount",                    precision: 8, scale: 2, default: 0.0
    t.decimal  "price_with_discount",              precision: 8, scale: 2, default: 0.0
    t.decimal  "available_qty",                    precision: 8, scale: 3, default: 0.0
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.string   "sku",                 limit: 255
  end

  add_index "articles", ["color_id"], name: "index_articles_on_color_id", using: :btree
  add_index "articles", ["product_id"], name: "index_articles_on_product_id", using: :btree
  add_index "articles", ["size_id"], name: "index_articles_on_size_id", using: :btree
  add_index "articles", ["sku"], name: "index_articles_on_sku", using: :btree

  create_table "blog_posts", force: :cascade do |t|
    t.string   "title",                     limit: 1024,  null: false
    t.string   "subtitle",                  limit: 2048
    t.text     "text",                      limit: 65535
    t.string   "source_title",              limit: 1024
    t.string   "source_link",               limit: 2048
    t.string   "main_picture_file_name",    limit: 255
    t.string   "main_picture_content_type", limit: 255
    t.integer  "main_picture_file_size",    limit: 4
    t.datetime "main_picture_updated_at"
    t.integer  "main_picture_width",        limit: 4
    t.integer  "main_picture_height",       limit: 4
    t.integer  "user_id",                   limit: 4,     null: false
    t.string   "url_path",                  limit: 255,   null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "blog_posts", ["url_path"], name: "index_blog_posts_on_url_path", unique: true, using: :btree

  create_table "campaign_groups", force: :cascade do |t|
    t.integer  "campaign_id",  limit: 4,                null: false
    t.string   "label",        limit: 2048,             null: false
    t.string   "see_more_url", limit: 1024
    t.integer  "order_index",  limit: 4,    default: 0, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "campaign_groups", ["campaign_id"], name: "index_campaign_groups_on_campaign_id", using: :btree

  create_table "campaign_objects", force: :cascade do |t|
    t.integer  "campaign_id", limit: 4,               null: false
    t.integer  "object_id",   limit: 4,               null: false
    t.string   "object_type", limit: 255,             null: false
    t.integer  "order_index", limit: 4,   default: 1, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "campaign_objects", ["campaign_id"], name: "index_campaign_objects_on_campaign_id", using: :btree
  add_index "campaign_objects", ["object_id", "object_type"], name: "index_campaign_objects_on_object_id_and_object_type", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "title",                limit: 1024,  null: false
    t.text     "description",          limit: 65535
    t.string   "url_path",             limit: 250,   null: false
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size",    limit: 4
    t.datetime "picture_updated_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "cart_deleted_details", force: :cascade do |t|
    t.integer  "article_id",          limit: 4,                         null: false
    t.integer  "user_id",             limit: 4
    t.decimal  "price",                         precision: 8, scale: 2
    t.decimal  "perc_discount",                 precision: 8, scale: 2
    t.decimal  "price_with_discount",           precision: 8, scale: 2
    t.decimal  "qty",                           precision: 8, scale: 3
    t.datetime "added_at",                                              null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "cart_deleted_details", ["article_id"], name: "index_cart_deleted_details_on_article_id", using: :btree

  create_table "cart_details", force: :cascade do |t|
    t.integer  "cart_id",             limit: 4,                                       null: false
    t.integer  "article_id",          limit: 4,                                       null: false
    t.decimal  "price",                         precision: 8, scale: 2, default: 0.0
    t.decimal  "perc_discount",                 precision: 8, scale: 2, default: 0.0
    t.decimal  "price_with_discount",           precision: 8, scale: 2, default: 0.0
    t.decimal  "qty",                           precision: 8, scale: 3, default: 0.0
    t.decimal  "total",                         precision: 8, scale: 2, default: 0.0
    t.decimal  "total_with_discount",           precision: 8, scale: 2, default: 0.0
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
  end

  add_index "cart_details", ["article_id"], name: "index_cart_details_on_article_id", using: :btree
  add_index "cart_details", ["cart_id"], name: "index_cart_details_on_cart_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "colors", force: :cascade do |t|
    t.string   "name",                 limit: 255,             null: false
    t.string   "code",                 limit: 10
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size",    limit: 4
    t.datetime "picture_updated_at"
    t.integer  "order_index",          limit: 4,   default: 1, null: false
    t.string   "key",                  limit: 128
  end

  add_index "colors", ["key"], name: "index_colors_on_key", unique: true, using: :btree

  create_table "contact_inquiries", force: :cascade do |t|
    t.integer  "user_id",       limit: 4,                 null: false
    t.string   "name",          limit: 1024,              null: false
    t.string   "email",         limit: 1024,              null: false
    t.string   "subject",       limit: 1024,              null: false
    t.text     "message",       limit: 65535,             null: false
    t.text     "reply_message", limit: 65535
    t.integer  "status",        limit: 4,     default: 1, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "contact_inquiries", ["user_id"], name: "index_contact_inquiries_on_user_id", using: :btree

  create_table "custom_tasks", force: :cascade do |t|
    t.string   "code",        limit: 128,             null: false
    t.integer  "in_progress", limit: 4,   default: 0, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "custom_tasks", ["code"], name: "index_custom_tasks_on_code", unique: true, using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "ga_page_views", force: :cascade do |t|
    t.integer  "related_model_id",   limit: 4
    t.string   "related_model_type", limit: 255
    t.integer  "user_id",            limit: 4
    t.datetime "view_date",                       null: false
    t.string   "previous_page",      limit: 4096
    t.string   "user_type",          limit: 128
    t.string   "device_category",    limit: 128
    t.string   "city",               limit: 512
    t.integer  "page_views",         limit: 4
    t.integer  "unique_page_views",  limit: 4
    t.integer  "time_on_page",       limit: 4
  end

  add_index "ga_page_views", ["related_model_id", "related_model_type"], name: "index_ga_page_views_on_related_model_id_and_related_model_type", using: :btree
  add_index "ga_page_views", ["user_id"], name: "index_ga_page_views_on_user_id", using: :btree

  create_table "home_page_links", force: :cascade do |t|
    t.string   "title",                limit: 2048
    t.string   "subtitle",             limit: 4096
    t.string   "url_path",             limit: 1024,             null: false
    t.integer  "position",             limit: 4,    default: 1, null: false
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size",    limit: 4
    t.datetime "picture_updated_at"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "home_page_objects", force: :cascade do |t|
    t.integer  "home_page_variant_id", limit: 4,               null: false
    t.integer  "object_id",            limit: 4,               null: false
    t.string   "object_type",          limit: 255,             null: false
    t.integer  "order_index",          limit: 4,   default: 1, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "home_page_objects", ["home_page_variant_id"], name: "index_home_page_objects_on_home_page_variant_id", using: :btree
  add_index "home_page_objects", ["object_id", "object_type"], name: "index_home_page_objects_on_object_id_and_object_type", using: :btree

  create_table "home_page_variants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "location_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "key",        limit: 255, null: false
    t.string   "short_name", limit: 30
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name",             limit: 1024,             null: false
    t.integer  "parent_id",        limit: 4
    t.integer  "order_index",      limit: 4,    default: 1, null: false
    t.integer  "location_type_id", limit: 4,                null: false
    t.string   "key",              limit: 10
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "locations", ["key"], name: "index_locations_on_key", unique: true, using: :btree
  add_index "locations", ["location_type_id"], name: "index_locations_on_location_type_id", using: :btree
  add_index "locations", ["parent_id"], name: "index_locations_on_parent_id", using: :btree

  create_table "merchant_bank_transfer_infos", force: :cascade do |t|
    t.string   "company_name", limit: 256
    t.string   "iban",         limit: 64
    t.string   "bic_code",     limit: 16
    t.string   "currency",     limit: 8
    t.string   "bank_name",    limit: 128
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "merchant_epay_infos", force: :cascade do |t|
    t.string   "min_code",            limit: 64
    t.string   "encrypted_secret",    limit: 1024, null: false
    t.string   "encrypted_secret_iv", limit: 1024, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "merchant_order_details", force: :cascade do |t|
    t.integer  "merchant_order_id",   limit: 4,                                       null: false
    t.integer  "article_id",          limit: 4,                                       null: false
    t.decimal  "price",                         precision: 8, scale: 2, default: 0.0
    t.decimal  "perc_discount",                 precision: 8, scale: 2, default: 0.0
    t.decimal  "price_with_discount",           precision: 8, scale: 2, default: 0.0
    t.decimal  "qty",                           precision: 8, scale: 3, default: 0.0
    t.decimal  "qty_to_return",                 precision: 8, scale: 3, default: 0.0, null: false
    t.decimal  "qty_returned",                  precision: 8, scale: 3, default: 0.0, null: false
    t.decimal  "total",                         precision: 8, scale: 2, default: 0.0
    t.decimal  "total_with_discount",           precision: 8, scale: 2, default: 0.0
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
  end

  add_index "merchant_order_details", ["article_id"], name: "index_merchant_order_details_on_article_id", using: :btree
  add_index "merchant_order_details", ["merchant_order_id"], name: "index_merchant_order_details_on_merchant_order_id", using: :btree

  create_table "merchant_order_quantities", force: :cascade do |t|
    t.integer  "merchant_order_detail_id", limit: 4,                                       null: false
    t.integer  "article_quantity_id",      limit: 4,                                       null: false
    t.decimal  "qty",                                precision: 8, scale: 3, default: 0.0
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
  end

  add_index "merchant_order_quantities", ["article_quantity_id"], name: "index_merchant_order_quantities_on_article_quantity_id", using: :btree
  add_index "merchant_order_quantities", ["merchant_order_detail_id"], name: "index_merchant_order_quantities_on_merchant_order_detail_id", using: :btree

  create_table "merchant_order_return_details", force: :cascade do |t|
    t.integer  "merchant_order_return_id", limit: 4,                                       null: false
    t.integer  "merchant_order_detail_id", limit: 4,                                       null: false
    t.decimal  "return_qty",                         precision: 8, scale: 3, default: 0.0
    t.integer  "return_type",              limit: 4,                         default: 1,   null: false
    t.integer  "status",                   limit: 4,                         default: 1,   null: false
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
  end

  add_index "merchant_order_return_details", ["merchant_order_detail_id"], name: "index_merchant_order_return_details_on_merchant_order_detail_id", using: :btree
  add_index "merchant_order_return_details", ["merchant_order_return_id"], name: "index_merchant_order_return_details_on_merchant_order_return_id", using: :btree

  create_table "merchant_order_returns", force: :cascade do |t|
    t.integer  "merchant_order_id", limit: 4,                 null: false
    t.integer  "user_id",           limit: 4,                 null: false
    t.text     "note_to_merchant",  limit: 65535
    t.string   "user_first_name",   limit: 1024
    t.string   "user_last_name",    limit: 1024
    t.string   "user_email",        limit: 255
    t.string   "user_phone",        limit: 255
    t.integer  "status",            limit: 4,     default: 1, null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "merchant_order_returns", ["merchant_order_id"], name: "index_merchant_order_returns_on_merchant_order_id", using: :btree
  add_index "merchant_order_returns", ["user_id"], name: "index_merchant_order_returns_on_user_id", using: :btree

  create_table "merchant_order_status_changes", force: :cascade do |t|
    t.integer  "merchant_order_id", limit: 4, null: false
    t.integer  "status_from",       limit: 4, null: false
    t.integer  "status_to",         limit: 4, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "merchant_order_status_changes", ["merchant_order_id"], name: "index_merchant_order_status_changes_on_merchant_order_id", using: :btree

  create_table "merchant_orders", force: :cascade do |t|
    t.integer  "order_id",                 limit: 4,                                           null: false
    t.integer  "merchant_id",              limit: 4,                                           null: false
    t.integer  "merchant_shipment_id",     limit: 4,                                           null: false
    t.decimal  "shipment_price",                         precision: 8, scale: 2, default: 0.0
    t.datetime "aprox_delivery_date_from"
    t.datetime "aprox_delivery_date_to"
    t.datetime "acknowledged_date"
    t.text     "note_to_user",             limit: 65535
    t.integer  "status",                   limit: 4,                             default: 1,   null: false
    t.string   "return_code",              limit: 255
    t.integer  "return_attempts",          limit: 4,                             default: 0,   null: false
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.integer  "merchant_payment_type_id", limit: 4,                                           null: false
    t.string   "payment_code",             limit: 255
    t.string   "number",                   limit: 255
    t.text     "cancellation_note",        limit: 65535
  end

  add_index "merchant_orders", ["merchant_id", "status"], name: "index_merchant_orders_on_merchant_id_and_status", using: :btree
  add_index "merchant_orders", ["merchant_id"], name: "index_merchant_orders_on_merchant_id", using: :btree
  add_index "merchant_orders", ["merchant_payment_type_id"], name: "index_merchant_orders_on_merchant_payment_type_id", using: :btree
  add_index "merchant_orders", ["number"], name: "index_merchant_orders_on_number", unique: true, using: :btree
  add_index "merchant_orders", ["order_id"], name: "index_merchant_orders_on_order_id", using: :btree
  add_index "merchant_orders", ["return_code"], name: "index_merchant_orders_on_return_code", unique: true, using: :btree

  create_table "merchant_payment_types", force: :cascade do |t|
    t.integer  "merchant_id",     limit: 4,               null: false
    t.integer  "payment_type_id", limit: 4,               null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "info_id",         limit: 4
    t.string   "info_type",       limit: 255
    t.integer  "active",          limit: 4,   default: 1, null: false
  end

  add_index "merchant_payment_types", ["info_id", "info_type"], name: "index_merchant_payment_types_on_info_id_and_info_type", using: :btree
  add_index "merchant_payment_types", ["merchant_id"], name: "index_merchant_payment_types_on_merchant_id", using: :btree
  add_index "merchant_payment_types", ["payment_type_id"], name: "index_merchant_payment_types_on_payment_type_id", using: :btree

  create_table "merchant_product_api_mappings", force: :cascade do |t|
    t.integer  "merchant_id", limit: 4
    t.string   "object_type", limit: 255, null: false
    t.integer  "object_id",   limit: 4,   null: false
    t.string   "input_value", limit: 220, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "merchant_product_api_mappings", ["merchant_id", "object_type", "input_value"], name: "merchant_product_api_mappings_input_value_to_object", unique: true, using: :btree

  create_table "merchant_products_sync_tasks", force: :cascade do |t|
    t.integer  "merchant_id",            limit: 4
    t.string   "cron_daily_update_time", limit: 255, null: false
    t.string   "scrape_url",             limit: 255, null: false
    t.string   "parser_class_name",      limit: 255, null: false
    t.integer  "in_progress",            limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "merchant_products_sync_tasks", ["merchant_id"], name: "index_merchant_products_sync_tasks_on_merchant_id", using: :btree

  create_table "merchant_settings", force: :cascade do |t|
    t.integer  "merchant_id", limit: 4,   null: false
    t.string   "key",         limit: 128, null: false
    t.string   "value",       limit: 512, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "merchant_settings", ["merchant_id", "key"], name: "index_merchant_settings_on_merchant_id_and_key", unique: true, using: :btree

  create_table "merchant_shipment_locs", force: :cascade do |t|
    t.integer  "merchant_shipment_id", limit: 4, null: false
    t.integer  "location_id",          limit: 4, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "merchant_shipment_locs", ["merchant_shipment_id"], name: "index_merchant_shipment_locs_on_merchant_shipment_id", using: :btree

  create_table "merchant_shipments", force: :cascade do |t|
    t.integer  "merchant_id",      limit: 4,                                          null: false
    t.integer  "shipment_type_id", limit: 4,                                          null: false
    t.integer  "payment_type_id",  limit: 4
    t.string   "name",             limit: 512,                          default: "",  null: false
    t.string   "description",      limit: 2048
    t.decimal  "price",                         precision: 8, scale: 2, default: 0.0
    t.decimal  "min_order_price",               precision: 8, scale: 2, default: 0.0
    t.integer  "period_from",      limit: 4,                            default: 0,   null: false
    t.integer  "period_to",        limit: 4,                            default: 0,   null: false
    t.integer  "period_type",      limit: 4,                            default: 1,   null: false
    t.integer  "active",           limit: 4,                            default: 1,   null: false
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
  end

  add_index "merchant_shipments", ["merchant_id"], name: "index_merchant_shipments_on_merchant_id", using: :btree

  create_table "merchant_users", force: :cascade do |t|
    t.integer  "merchant_id", limit: 4
    t.integer  "user_id",     limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "merchant_users", ["merchant_id"], name: "index_merchant_users_on_merchant_id", using: :btree
  add_index "merchant_users", ["user_id"], name: "index_merchant_users_on_user_id", using: :btree

  create_table "merchants", force: :cascade do |t|
    t.string   "name",                limit: 1024
    t.string   "logo_file_name",      limit: 255
    t.string   "logo_content_type",   limit: 255
    t.integer  "logo_file_size",      limit: 4
    t.datetime "logo_updated_at"
    t.float    "rating",              limit: 24
    t.string   "website",             limit: 4096
    t.text     "description",         limit: 65535
    t.text     "return_policy",       limit: 65535
    t.integer  "return_days",         limit: 4,     default: 14, null: false
    t.integer  "status",              limit: 4,     default: 1,  null: false
    t.string   "url_path",            limit: 255,                null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.text     "return_instructions", limit: 65535
    t.string   "phone",               limit: 255
  end

  add_index "merchants", ["url_path"], name: "index_merchants_on_url_path", unique: true, using: :btree

  create_table "newsletter_subscribers", force: :cascade do |t|
    t.string   "email",      limit: 255,             null: false
    t.integer  "user_id",    limit: 4,               null: false
    t.integer  "active",     limit: 4,   default: 1, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "newsletter_subscribers", ["email"], name: "index_newsletter_subscribers_on_email", unique: true, using: :btree

  create_table "occasions", force: :cascade do |t|
    t.string   "name",        limit: 1024,              null: false
    t.text     "description", limit: 65535
    t.string   "key",         limit: 128,               null: false
    t.string   "url_path",    limit: 255,               null: false
    t.integer  "order_index", limit: 4,     default: 1, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "occasions", ["key"], name: "index_occasions_on_key", unique: true, using: :btree
  add_index "occasions", ["url_path"], name: "index_occasions_on_url_path", unique: true, using: :btree

  create_table "open_graph_tags", force: :cascade do |t|
    t.string   "page_link",            limit: 1500, null: false
    t.string   "title",                limit: 512
    t.string   "description",          limit: 1024
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size",    limit: 4
    t.datetime "picture_updated_at"
    t.integer  "picture_width",        limit: 4
    t.integer  "picture_height",       limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "open_graph_tags", ["page_link"], name: "index_open_graph_tags_on_page_link", length: {"page_link"=>255}, using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",            limit: 4,                 null: false
    t.integer  "only_business_days", limit: 4,     default: 1
    t.integer  "issue_invoice",      limit: 4,     default: 0, null: false
    t.text     "note_to_merchants",  limit: 65535
    t.string   "user_first_name",    limit: 1024
    t.string   "user_last_name",     limit: 1024
    t.string   "user_email",         limit: 255
    t.string   "user_phone",         limit: 255
    t.integer  "status",             limit: 4,     default: 1, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "outfit_categories", force: :cascade do |t|
    t.string   "name",        limit: 255,               null: false
    t.text     "description", limit: 65535
    t.string   "key",         limit: 128,               null: false
    t.string   "url_path",    limit: 255,               null: false
    t.integer  "order_index", limit: 4,     default: 1, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "outfit_categories", ["key"], name: "index_outfit_categories_on_key", unique: true, using: :btree
  add_index "outfit_categories", ["url_path"], name: "index_outfit_categories_on_url_path", unique: true, using: :btree

  create_table "outfit_decorations", force: :cascade do |t|
    t.integer  "category",             limit: 4,   default: 1, null: false
    t.integer  "order_index",          limit: 4,   default: 1, null: false
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size",    limit: 4
    t.datetime "picture_updated_at"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "parent_id",            limit: 4
  end

  add_index "outfit_decorations", ["category"], name: "index_outfit_decorations_on_category", using: :btree
  add_index "outfit_decorations", ["parent_id"], name: "index_outfit_decorations_on_parent_id", using: :btree

  create_table "outfit_occasions", force: :cascade do |t|
    t.integer  "outfit_id",   limit: 4, null: false
    t.integer  "occasion_id", limit: 4, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "outfit_occasions", ["occasion_id"], name: "index_outfit_occasions_on_occasion_id", using: :btree
  add_index "outfit_occasions", ["outfit_id"], name: "index_outfit_occasions_on_outfit_id", using: :btree

  create_table "outfit_product_pictures", force: :cascade do |t|
    t.integer  "outfit_id",          limit: 4, null: false
    t.integer  "product_picture_id", limit: 4, null: false
    t.integer  "instances_count",    limit: 4, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "outfit_product_pictures", ["outfit_id"], name: "index_outfit_product_pictures_on_outfit_id", using: :btree
  add_index "outfit_product_pictures", ["product_picture_id"], name: "index_outfit_product_pictures_on_product_picture_id", using: :btree

  create_table "outfit_sets", force: :cascade do |t|
    t.integer  "outfit_category_id",    limit: 4
    t.integer  "occasion_id",           limit: 4
    t.text     "description",           limit: 65535
    t.string   "meta_title",            limit: 255
    t.string   "meta_description",      limit: 512
    t.string   "og_image_file_name",    limit: 255
    t.string   "og_image_content_type", limit: 255
    t.integer  "og_image_file_size",    limit: 4
    t.datetime "og_image_updated_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "outfit_sets", ["outfit_category_id", "occasion_id"], name: "index_outfit_sets_on_outfit_category_id_and_occasion_id", unique: true, using: :btree

  create_table "outfits", force: :cascade do |t|
    t.string   "name",                 limit: 1024
    t.integer  "user_id",              limit: 4,                        null: false
    t.integer  "profile_id",           limit: 4,                        null: false
    t.float    "rating",               limit: 24,         default: 0.0, null: false
    t.integer  "outfit_category_id",   limit: 4,                        null: false
    t.integer  "image_filter",         limit: 4
    t.string   "url_path",             limit: 1050,                     null: false
    t.text     "serialized_json",      limit: 65535
    t.binary   "serialized_svg",       limit: 4294967295
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size",    limit: 4
    t.datetime "picture_updated_at"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "outfits", ["outfit_category_id"], name: "index_outfits_on_outfit_category_id", using: :btree
  add_index "outfits", ["profile_id"], name: "index_outfits_on_profile_id", using: :btree

  create_table "payment_types", force: :cascade do |t|
    t.string   "name",                 limit: 255,                   null: false
    t.text     "description",          limit: 65535
    t.datetime "picture_updated_at"
    t.integer  "picture_file_size",    limit: 4
    t.string   "picture_content_type", limit: 255
    t.string   "picture_file_name",    limit: 255
    t.integer  "order_index",          limit: 4,     default: 1,     null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "requires_action",                    default: false
    t.string   "info_class_name",      limit: 255
  end

  create_table "product_categories", force: :cascade do |t|
    t.string   "name",                  limit: 1024,              null: false
    t.text     "description",           limit: 65535
    t.string   "key",                   limit: 128,               null: false
    t.integer  "parent_id",             limit: 4
    t.integer  "status",                limit: 4,     default: 1, null: false
    t.string   "url_path",              limit: 255,               null: false
    t.string   "meta_title",            limit: 255
    t.string   "meta_description",      limit: 512
    t.datetime "og_image_updated_at"
    t.integer  "og_image_file_size",    limit: 4
    t.string   "og_image_content_type", limit: 255
    t.string   "og_image_file_name",    limit: 255
    t.integer  "order_index",           limit: 4,     default: 1, null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "product_categories", ["key"], name: "index_product_categories_on_key", unique: true, using: :btree
  add_index "product_categories", ["parent_id"], name: "index_product_categories_on_parent_id", using: :btree
  add_index "product_categories", ["url_path"], name: "index_product_categories_on_url_path", using: :btree

  create_table "product_collections", force: :cascade do |t|
    t.integer  "merchant_id",          limit: 4,     null: false
    t.string   "name",                 limit: 512,   null: false
    t.text     "description",          limit: 65535
    t.integer  "season_id",            limit: 4,     null: false
    t.integer  "year",                 limit: 4,     null: false
    t.string   "url_path",             limit: 255,   null: false
    t.datetime "picture_updated_at"
    t.integer  "picture_file_size",    limit: 4
    t.string   "picture_content_type", limit: 255
    t.string   "picture_file_name",    limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "product_collections", ["merchant_id"], name: "index_product_collections_on_merchant_id", using: :btree

  create_table "product_colors", force: :cascade do |t|
    t.integer  "product_id", limit: 4, null: false
    t.integer  "color_id",   limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "product_colors", ["product_id"], name: "index_product_colors_on_product_id", using: :btree

  create_table "product_occasions", force: :cascade do |t|
    t.integer  "product_id",  limit: 4, null: false
    t.integer  "occasion_id", limit: 4, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "product_occasions", ["occasion_id"], name: "index_product_occasions_on_occasion_id", using: :btree
  add_index "product_occasions", ["product_id"], name: "index_product_occasions_on_product_id", using: :btree

  create_table "product_pictures", force: :cascade do |t|
    t.integer  "product_id",                  limit: 4
    t.string   "picture_file_name",           limit: 255
    t.string   "picture_content_type",        limit: 255
    t.integer  "picture_file_size",           limit: 4
    t.datetime "picture_updated_at"
    t.integer  "outfit_compatible",           limit: 4,    default: 0, null: false
    t.integer  "order_index",                 limit: 4,                null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "color_id",                    limit: 4
    t.string   "source_url",                  limit: 2048
    t.integer  "original_product_picture_id", limit: 4
  end

  add_index "product_pictures", ["product_id"], name: "index_product_pictures_on_product_id", using: :btree

  create_table "product_sizes", force: :cascade do |t|
    t.integer  "product_id", limit: 4, null: false
    t.integer  "size_id",    limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "product_sizes", ["product_id"], name: "index_product_sizes_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "merchant_id",                         limit: 4,                                           null: false
    t.integer  "trade_mark_id",                       limit: 4
    t.integer  "user_id",                             limit: 4,                                           null: false
    t.string   "name",                                limit: 1024,                                        null: false
    t.text     "description",                         limit: 65535
    t.integer  "status",                              limit: 4,                             default: 1,   null: false
    t.integer  "product_category_id",                 limit: 4,                                           null: false
    t.float    "rating",                              limit: 24,                            default: 0.0, null: false
    t.string   "url_path",                            limit: 1050,                                        null: false
    t.datetime "created_at",                                                                              null: false
    t.datetime "updated_at",                                                                              null: false
    t.integer  "product_collection_id",               limit: 4
    t.decimal  "min_available_qty",                                 precision: 8, scale: 3
    t.string   "catalog_picture_file_name",           limit: 255
    t.string   "catalog_picture_content_type",        limit: 255
    t.integer  "catalog_picture_file_size",           limit: 4
    t.datetime "catalog_picture_updated_at"
    t.string   "catalog_square_picture_file_name",    limit: 255
    t.string   "catalog_square_picture_content_type", limit: 255
    t.integer  "catalog_square_picture_file_size",    limit: 4
    t.datetime "catalog_square_picture_updated_at"
    t.string   "picture_watermark_url",               limit: 1024
  end

  add_index "products", ["merchant_id"], name: "index_products_on_merchant_id", using: :btree
  add_index "products", ["product_category_id"], name: "index_products_on_product_category_id", using: :btree
  add_index "products", ["product_collection_id"], name: "index_products_on_product_collection_id", using: :btree
  add_index "products", ["trade_mark_id"], name: "index_products_on_trade_mark_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4
    t.string   "owner_type", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "profiles", ["owner_id", "owner_type"], name: "index_profiles_on_owner_id_and_owner_type", unique: true, using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4,   null: false
    t.string   "owner_type", limit: 255, null: false
    t.integer  "profile_id", limit: 4,   null: false
    t.integer  "user_id",    limit: 4,   null: false
    t.float    "rating",     limit: 24,  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "ratings", ["owner_type", "owner_id"], name: "index_ratings_on_owner_type_and_owner_id", using: :btree
  add_index "ratings", ["profile_id", "owner_type", "owner_id"], name: "index_ratings_on_profile_id_and_owner_type_and_owner_id", unique: true, using: :btree

  create_table "registered_user_guests", force: :cascade do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.integer  "guest_id",   limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "registered_user_guests", ["guest_id"], name: "index_registered_user_guests_on_guest_id", using: :btree

  create_table "request_execution_times", force: :cascade do |t|
    t.string   "measure_type", limit: 255
    t.float    "request_time", limit: 24
    t.datetime "scanned_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "num_requests", limit: 4
  end

  add_index "request_execution_times", ["created_at"], name: "index_request_execution_times_on_created_at", using: :btree
  add_index "request_execution_times", ["measure_type"], name: "index_request_execution_times_on_measure_type", using: :btree

  create_table "search_pages", force: :cascade do |t|
    t.string   "title",                 limit: 1024,  null: false
    t.text     "description",           limit: 65535
    t.string   "url_path",              limit: 250,   null: false
    t.string   "meta_title",            limit: 255
    t.string   "meta_description",      limit: 512
    t.datetime "og_image_updated_at"
    t.integer  "og_image_file_size",    limit: 4
    t.string   "og_image_content_type", limit: 255
    t.string   "og_image_file_name",    limit: 255
    t.integer  "category",              limit: 4,     null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "search_pages", ["url_path", "category"], name: "index_search_pages_on_url_path_and_category", unique: true, using: :btree

  create_table "seasons", force: :cascade do |t|
    t.string   "name",        limit: 255,             null: false
    t.integer  "order_index", limit: 4,   default: 1, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "shipment_types", force: :cascade do |t|
    t.string   "name",                 limit: 512,               null: false
    t.text     "description",          limit: 65535
    t.datetime "picture_updated_at"
    t.integer  "picture_file_size",    limit: 4
    t.string   "picture_content_type", limit: 255
    t.string   "picture_file_name",    limit: 255
    t.integer  "order_index",          limit: 4,     default: 1, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "size_categories", force: :cascade do |t|
    t.string   "name",        limit: 255,             null: false
    t.integer  "order_index", limit: 4,   default: 1, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "size_category_descriptors", force: :cascade do |t|
    t.integer  "size_category_id",   limit: 4, null: false
    t.integer  "size_descriptor_id", limit: 4, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "size_category_descriptors", ["size_category_id"], name: "index_size_category_descriptors_on_size_category_id", using: :btree

  create_table "size_category_product_categories", force: :cascade do |t|
    t.integer  "size_category_id",    limit: 4, null: false
    t.integer  "product_category_id", limit: 4, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "size_category_product_categories", ["product_category_id"], name: "index_size_category_product_categories_on_product_category_id", using: :btree
  add_index "size_category_product_categories", ["size_category_id"], name: "index_size_category_product_categories_on_size_category_id", using: :btree

  create_table "size_chart_descriptors", force: :cascade do |t|
    t.integer  "size_chart_id",      limit: 4,                                       null: false
    t.integer  "size_id",            limit: 4,                                       null: false
    t.integer  "size_descriptor_id", limit: 4,                                       null: false
    t.decimal  "value_from",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "value_to",                     precision: 8, scale: 2, default: 0.0, null: false
    t.integer  "order_index",        limit: 4,                         default: 1,   null: false
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
  end

  add_index "size_chart_descriptors", ["size_chart_id"], name: "index_size_chart_descriptors_on_size_chart_id", using: :btree

  create_table "size_charts", force: :cascade do |t|
    t.string   "name",             limit: 1024,  default: "", null: false
    t.integer  "merchant_id",      limit: 4,                  null: false
    t.integer  "size_category_id", limit: 4,                  null: false
    t.text     "note",             limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "size_charts", ["merchant_id", "size_category_id"], name: "index_size_charts_on_merchant_id_and_size_category_id", using: :btree
  add_index "size_charts", ["merchant_id"], name: "index_size_charts_on_merchant_id", using: :btree

  create_table "size_descriptors", force: :cascade do |t|
    t.string   "name",        limit: 1024,             null: false
    t.integer  "order_index", limit: 4,    default: 1, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "sizes", force: :cascade do |t|
    t.string   "name",             limit: 255,             null: false
    t.integer  "order_index",      limit: 4,   default: 1, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "size_category_id", limit: 4
    t.string   "key",              limit: 128
  end

  add_index "sizes", ["key"], name: "index_sizes_on_key", unique: true, using: :btree
  add_index "sizes", ["size_category_id"], name: "index_sizes_on_size_category_id", using: :btree

  create_table "trade_marks", force: :cascade do |t|
    t.string   "name",              limit: 1024
    t.string   "logo_file_name",    limit: 255
    t.string   "logo_content_type", limit: 255
    t.integer  "logo_file_size",    limit: 4
    t.datetime "logo_updated_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "key",               limit: 128
  end

  add_index "trade_marks", ["key"], name: "index_trade_marks_on_key", unique: true, using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "role",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "email",                  limit: 255,  default: "",   null: false
    t.string   "encrypted_password",     limit: 255,  default: "",   null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,    default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "failed_attempts",        limit: 4,    default: 0,    null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.string   "username",               limit: 255,                 null: false
    t.string   "first_name",             limit: 1024, default: ""
    t.string   "last_name",              limit: 1024, default: ""
    t.string   "phone",                  limit: 255
    t.float    "rating",                 limit: 24
    t.string   "gender",                 limit: 1
    t.date     "birth_date"
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size",       limit: 4
    t.datetime "avatar_updated_at"
    t.integer  "status",                 limit: 4,    default: 1,    null: false
    t.boolean  "email_promotions",                    default: true, null: false
    t.integer  "profile_id",             limit: 4
    t.string   "url_path",               limit: 255,                 null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["email_promotions"], name: "index_users_on_email_promotions", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  add_index "users", ["url_path"], name: "index_users_on_url_path", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
