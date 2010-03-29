class CreateSponsoredArticles < ActiveRecord::Migration
  def self.up
    create_table :sponsored_articles do |t|
      t.string :url
      t.integer :pagerank
      t.integer :users_daily
      t.integer :words_number, :null => false, :default => 0
      t.integer :number_of_links
      t.references :auction
      t.timestamps
    end
    execute "ALTER TABLE sponsored_articles ADD CONSTRAINT fk_sponsored_articles_for_auctions_1 FOREIGN KEY (auction_id) REFERENCES auctions;"
  end

  def self.down
    execute "ALTER TABLE sponsored_articles DROP CONSTRAINT fk_sponsored_articles_for_auctions_1;"
    drop_table :sponsored_articles
  end
end
