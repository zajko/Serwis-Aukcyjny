class DropAuctionIdFromProducts < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE banners DROP CONSTRAINT fk_banners_for_auctions_1;"
    remove_column :banners, :auction_id
    execute "ALTER TABLE site_links DROP CONSTRAINT fk_site_links_for_auctions_1;"
    remove_column :site_links, :auction_id
    execute "ALTER TABLE sponsored_articles DROP CONSTRAINT fk_sponsored_articles_for_auctions_1;"
    remove_column :sponsored_articles, :auction_id

  end

  def self.down
    add_column :banners, :auction_id, :integer
    execute "ALTER TABLE banners ADD CONSTRAINT fk_banners_for_auctions_1 FOREIGN KEY (auction_id) REFERENCES auctions;"
    add_column :site_links, :auction_id, :integer
    execute "ALTER TABLE site_links ADD CONSTRAINT fk_site_links_for_auctions_1 FOREIGN KEY (auction_id) REFERENCES auctions;"
    add_column :sponsored_articles, :auction_id, :integer
    execute "ALTER TABLE sponsored_articles ADD CONSTRAINT fk_sponsored_articles_for_auctions_1 FOREIGN KEY (auction_id) REFERENCES auctions;"
  end
end
