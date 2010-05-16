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

ActiveRecord::Schema.define(:version => 20100516130704) do

  create_table "archival_auctions", :force => true do |t|
    t.integer  "archival_auction_owner_id"
    t.string   "archival_auction_owner_type"
    t.datetime "start",                                                      :null => false
    t.datetime "auction_end",                                                :null => false
    t.integer  "number_of_products",                                         :null => false
    t.decimal  "minimal_price",               :precision => 14, :scale => 4, :null => false
    t.decimal  "buy_now_price",               :precision => 14, :scale => 4, :null => false
    t.decimal  "minimal_bidding_difference",  :precision => 10, :scale => 2, :null => false
    t.decimal  "current_price",               :precision => 14, :scale => 4, :null => false
    t.integer  "time_of_service",                                            :null => false
    t.boolean  "activated",                                                  :null => false
    t.integer  "archival_auctionable_id"
    t.string   "archival_auctionable_type"
    t.datetime "auction_created_time",                                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archival_bids", :force => true do |t|
    t.integer  "archival_auction_id"
    t.integer  "archival_biddable_id"
    t.string   "archival_biddable_type"
    t.integer  "archival_bid_owner_id"
    t.string   "archival_bid_owner_type"
    t.decimal  "offered_price",           :precision => 14, :scale => 4
    t.boolean  "cancelled",                                              :default => false
    t.boolean  "asking_for_cancellation",                                :default => false
    t.datetime "bid_created_time",                                                          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archival_users", :force => true do |t|
    t.string   "login",                               :null => false
    t.string   "email",                               :null => false
    t.string   "crypted_password",                    :null => false
    t.string   "password_salt",                       :null => false
    t.string   "first_name",         :default => " ", :null => false
    t.string   "surname",            :default => " ", :null => false
    t.datetime "user_creation_time",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", :force => true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["attachable_id", "attachable_type"], :name => "index_attachments_on_attachable_id_and_attachable_type"

  create_table "auctions", :force => true do |t|
    t.integer  "user_id",                                                                      :null => false
    t.datetime "start",                                                                        :null => false
    t.datetime "auction_end",                                                                  :null => false
    t.integer  "number_of_products",                                        :default => 1
    t.decimal  "minimal_price",              :precision => 14, :scale => 4, :default => 0.0
    t.decimal  "buy_now_price",              :precision => 14, :scale => 4, :default => 0.0
    t.decimal  "minimal_bidding_difference", :precision => 10, :scale => 2, :default => 5.0
    t.decimal  "current_price",              :precision => 14, :scale => 4, :default => 0.0,   :null => false
    t.integer  "time_of_service",                                           :default => 50,    :null => false
    t.integer  "integer",                                                   :default => 50,    :null => false
    t.boolean  "activated",                                                 :default => false
    t.string   "activation_token"
    t.integer  "auctionable_id"
    t.string   "auctionable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auctions_categories", :id => false, :force => true do |t|
    t.integer  "auction_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auctions_users", :id => false, :force => true do |t|
    t.integer  "auction_id", :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "banners", :force => true do |t|
    t.string   "url"
    t.integer  "pagerank",                                  :default => 0
    t.integer  "users_daily",                               :default => 0
    t.integer  "width",                                                      :null => false
    t.integer  "height",                                                     :null => false
    t.integer  "x_pos",                                                      :null => false
    t.integer  "y_pos",                                                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "frequency",   :precision => 5, :scale => 4, :default => 1.0
  end

  create_table "bids", :force => true do |t|
    t.integer  "user_id"
    t.integer  "auction_id"
    t.decimal  "offered_price",           :precision => 14, :scale => 4
    t.boolean  "cancelled",                                              :default => false
    t.boolean  "asking_for_cancellation",                                :default => false
    t.datetime "bid_created_time",                                                          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buy_now_auctions", :force => true do |t|
    t.decimal  "price",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "charges", :force => true do |t|
    t.decimal  "sum",                :precision => 14, :scale => 4, :null => false
    t.integer  "chargeable_id"
    t.string   "chargeable_type"
    t.integer  "charges_owner_id"
    t.string   "charges_owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interests", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "interests", ["name"], :name => "index_interests_on_name", :unique => true

  create_table "interests_users", :id => false, :force => true do |t|
    t.integer  "interest_id", :null => false
    t.integer  "user_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailing_services", :force => true do |t|
    t.integer  "recipients_number",                                :null => false
    t.integer  "number_of_emails_to_one_recipient", :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_politics", :force => true do |t|
    t.datetime "from"
    t.datetime "to"
    t.decimal  "base_payment",                :precision => 14, :scale => 4, :default => 0.0, :null => false
    t.decimal  "upper_boundary",              :precision => 14, :scale => 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "percentage",     :limit => 2, :precision => 2,  :scale => 0, :default => 0
  end

  create_table "payments", :force => true do |t|
    t.decimal  "sum",                :precision => 14, :scale => 4, :null => false
    t.integer  "payable_id"
    t.string   "payable_type"
    t.integer  "payment_owner_id"
    t.string   "payment_owner_type"
    t.integer  "archival_user_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pop_ups", :force => true do |t|
    t.string   "url"
    t.integer  "pagerank",                                  :default => 0
    t.integer  "users_daily",                               :default => 0
    t.integer  "width",                                                      :null => false
    t.integer  "height",                                                     :null => false
    t.decimal  "frequency",   :precision => 5, :scale => 4, :default => 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.integer  "auction_id"
    t.text     "product_token",                    :null => false
    t.text     "url"
    t.boolean  "activated",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "authorizable_type"
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "destructible",      :default => true
  end

  add_index "roles", ["name", "authorizable_type", "authorizable_id"], :name => "index_roles_on_name_and_authorizable_type_and_authorizable_id", :unique => true

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "role_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_links", :force => true do |t|
    t.string   "url",                        :null => false
    t.integer  "pagerank",    :default => 0, :null => false
    t.integer  "users_daily", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsored_articles", :force => true do |t|
    t.string   "url"
    t.integer  "pagerank",        :default => 0
    t.integer  "users_daily",     :default => 0
    t.integer  "words_number",    :default => 0, :null => false
    t.integer  "number_of_links"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                :null => false
    t.string   "email",                                :null => false
    t.string   "crypted_password",                     :null => false
    t.string   "password_salt",                        :null => false
    t.string   "persistence_token",                    :null => false
    t.string   "single_access_token",                  :null => false
    t.string   "perishable_token",                     :null => false
    t.integer  "login_count",         :default => 0,   :null => false
    t.integer  "failed_login_count",  :default => 0,   :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "first_name",          :default => " ", :null => false
    t.string   "surname",             :default => " ", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_token",    :default => "",  :null => false
  end

end
