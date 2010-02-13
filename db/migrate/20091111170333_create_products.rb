class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.references :auction
      t.text :product_token, :length => 20, :null => false
      t.text :url
      t.boolean :activated, :default => false
      
      t.timestamps
    end
    execute "ALTER TABLE products ADD CONSTRAINT fk_products_to_auctions_1 FOREIGN KEY (auction_id) REFERENCES auctions"
  end

  def self.down
    drop_table :products
  end
end
