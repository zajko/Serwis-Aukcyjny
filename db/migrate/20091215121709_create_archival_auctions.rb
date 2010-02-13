class CreateArchivalAuctions < ActiveRecord::Migration
  def self.up
    create_table :archival_auctions do |t|
      #t.references :archival_user  #Jeżeli aukcja została zarchiwizowana i użytkownik też jest już w arhiwum
      #t.references :user  #Jeżeli aukcja została zarchiwizowana ale użytkownik jeszcze działa, archival_user i user powinno być XOR (jedno z nich musi być null)
      t.references :archival_auction_owner, :polymorphic => true
      t.datetime :start, :null => false
      t.datetime :auction_end, :null => false
      t.integer :number_of_products, :null => false
      t.decimal :minimal_price, :null => false, :precision => 14, :scale => 4
      t.decimal :buy_now_price, :null => false, :precision => 14, :scale => 4
      t.decimal :minimal_bidding_difference, :null => false,  :precision => 10, :scale => 2
      t.decimal :current_price, :precision => 14, :scale => 4, :null => false
      t.integer :time_of_service, :null => false
      t.boolean :activated, :null => false
      #t.string :activation_token , :length => 20
      t.references :archival_auctionable, :polymorphic => true
      t.datetime :auction_created_time, :null => false
      t.timestamps
    end
    #execute "ALTER TABLE archival_auctions ADD CONSTRAINT fk_archival_auctions_to_archival_users FOREIGN KEY (archival_user_id) REFERENCES archival_users;"
  end

  def self.down
    #execute "ALTER TABLE archival_auctions DROP CONSTRAINT fk_archival_auctions_to_archival_users;"
    drop_table :archival_auctions
  end
end
