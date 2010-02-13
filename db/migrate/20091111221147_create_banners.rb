class CreateBanners < ActiveRecord::Migration
  def self.up
    create_table :banners do |t|
      t.string :url
      t.integer :pagerank
      t.integer :users_daily
      t.integer :width, :null=> false
      t.integer :height, :null=> false
      t.integer :x_pos, :null=> false
      t.integer :y_pos, :null=> false
      t.references :auction
      t.timestamps
  def self.prepare_search_scopes(params = {})
    scope = Banner.search(:all)#Auction.search(:auctionable_type => params[:product_type].classify, :activated => true)
    scope = scope.pagerank_gte(params[:pagerank_gte]) if params[:pagerank_gte].to_i > 0
    scope = scope.pagerank_lte(params[:pagerank_lte]) if params[:pagerank_lte].to_i > 0
    scope = scope.users_daily_gte(params[:users_daily_gte]) if params[:users_daily_gte].to_i > 0
    scope = scope.users_daily_lte(params[:users_daily_lte]) if params[:users_daily_lte].to_i > 0
    scope = scope.x_pos_gte(params[:x_pos_gte]) if params[:users_daily_gte].to_i > 0
    scope = scope.x_pos_lte(params[:x_pos_lte]) if params[:users_daily_lte].to_i > 0
    scope = scope.y_pos_gte(params[:y_pos_gte]) if params[:users_daily_gte].to_i > 0
    scope = scope.y_pos_lte(params[:y_pos_lte]) if params[:users_daily_lte].to_i > 0
    scope = scope.width_gte(params[:width_pos_gte]) if params[:users_daily_gte].to_i > 0
    scope = scope.height_lte(params[:height_pos_lte]) if params[:users_daily_lte].to_i > 0
    return scope
  end
    end
    execute "ALTER TABLE banners ADD CONSTRAINT fk_banners_for_auctions_1 FOREIGN KEY (auction_id) REFERENCES auctions;"
  end

  def self.down
    execute "ALTER TABLE banners DROP CONSTRAINT fk_banners_for_auctions_1;"
    drop_table :banners
  end
end
