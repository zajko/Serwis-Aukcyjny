class CreateArchivalBids < ActiveRecord::Migration
  def self.up
    create_table :archival_bids do |t|
      #t.references :archival_user #Jeżeli uzytkownik, który złożył ofertę został już zarchiwizowany
      #t.references :user #Jeżeli uzytkownik, który złożył ofertę został jest w systemie. archival_user i user powinny być rozłączne (jeden z nich powinien być nullem)
      t.references :archival_auction
      t.references :archival_bid_owner, :polymorphic => true
      t.decimal :offered_price, :precision => 14, :scale => 4
      t.boolean :cancelled, :default => false
      t.boolean :asking_for_cancellation, :default => false
      t.datetime :bid_created_time, :null => false
      t.timestamps
    end
    #execute "ALTER TABLE archival_bids ADD CONSTRAINT fk_archival_bids_to_archival_user FOREIGN KEY (archival_user_id) REFERENCES archival_users;"
    #execute "ALTER TABLE archival_bids ADD CONSTRAINT fk_archival_bids_to_archival_auction FOREIGN KEY (archival_auction_id) REFERENCES archival_auctions;"
  end
  

  def self.down
    #execute "ALTER TABLE archival_bids DROP CONSTRAINT fk_archival_bids_to_archival_user;"
    #execute "ALTER TABLE archival_bids DROP CONSTRAINT fk_archival_bids_to_archival_auction;"
    drop_table :archival_bids
  end
end
