class AuctionsUsers < ActiveRecord::Migration
  def self.up
    create_table :auctions_users, :id => false do |t|
      t.references :auction, :user, :null => false
      t.timestamps
    end
    execute "ALTER TABLE auctions_users ADD CONSTRAINT fk_auction_user_1 FOREIGN KEY (user_id) REFERENCES users;"
     execute "ALTER TABLE auctions_users ADD CONSTRAINT fk_auction_user_2 FOREIGN KEY (auction_id) REFERENCES auctions;"
     execute "alter TABLE auctions_users add constraint pk_auctions_users PRIMARY KEY (auction_id, user_id);"

  end

  def self.down
    execute "alter TABLE auctions_users DROP constraint pk_auctions_users;"
    execute "ALTER TABLE auctions_users DROP CONSTRAINT fk_auctions_user_1;"
    execute "ALTER TABLE auctions_users DROP CONSTRAINT fk_auctions_user_2;"
    drop_table :roles_users
  end

end
