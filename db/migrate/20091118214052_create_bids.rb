class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.references :user
      t.references :auction
      t.decimal :offered_price, :precision => 14, :scale => 4
      t.boolean :cancelled, :default => false
      t.boolean :asking_for_cancellation, :default => false
      t.datetime :bid_created_time, :null=>false
      t.timestamps
    end
    execute "ALTER TABLE bids ADD CONSTRAINT fk_bids_to_user FOREIGN KEY (user_id) REFERENCES users;"
    execute "ALTER TABLE bids ADD CONSTRAINT fk_bids_to_auction FOREIGN KEY (auction_id) REFERENCES auctions;"
  end
  

  def self.down
    execute "ALTER TABLE bids DROP CONSTRAINT fk_bids_to_user;"
    execute "ALTER TABLE bids DROP CONSTRAINT fk_bids_to_auction;"
    drop_table :bids
  end
end
