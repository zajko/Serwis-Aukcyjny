class CreateSiteLinks < ActiveRecord::Migration
  def self.up
    create_table :site_links do |t|
      t.string :url, :null => false
      t.integer :pagerank, :null => false
      t.integer :users_daily
      t.references :auction
      t.timestamps
    end
    execute "ALTER TABLE site_links ADD CONSTRAINT fk_site_links_for_auctions_1 FOREIGN KEY (auction_id) REFERENCES auctions;"
  end
  

  def self.down
    execute "ALTER TABLE site_links DROP CONSTRAINT fk_site_links_for_auctions_1;"
    drop_table :site_links
  end
end
