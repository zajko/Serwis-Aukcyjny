class CreateAuctions < ActiveRecord::Migration
  def self.up
    create_table :auctions do |t|
      t.references :user , :null => false
      
      t.datetime :start, :null => false
      t.datetime :auction_end, :null => false
      t.integer :number_of_products, :default => 1
      t.decimal :minimal_price, :default => 0, :precision => 14, :scale => 4
      t.decimal :buy_now_price, :default => 0, :precision => 14, :scale => 4
      t.decimal :minimal_bidding_difference, :default => 5.00,  :precision => 10, :scale => 2
      t.decimal :current_price, :precision => 14, :scale => 4, :default =>  0.0, :null => false
      t.integer :time_of_service, :integer, :default => 50, :null => false

      t.boolean :activated, :default => false
      t.string :activation_token , :length => 20
      t.references :auctionable, :polymorphic => true
     # t.text :auction_token, :length => 20, :null => false
  #    t.integer :page_rank, :null => false
      t.timestamps
    end
    execute "ALTER TABLE auctions ADD CONSTRAINT fk_auctions_to_users FOREIGN KEY (user_id) REFERENCES users;"
  end

  def self.down
    drop_table :auctions
    execute "ALTER TABLE auctions DROP CONSTRAINT fk_auctions_to_users; "
    #execute "DROP CONSTRAINT 'fk_auctions_1' "
  end
end
