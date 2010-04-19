class RemoveForeignKeyUserAuction < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE auctions DROP CONSTRAINT fk_auctions_to_users; "
  end

  def self.down
     execute "ALTER TABLE auctions ADD CONSTRAINT fk_auctions_to_users FOREIGN KEY (user_id) REFERENCES users;"
  end
end
