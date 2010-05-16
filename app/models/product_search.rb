
class ProductSearch < Tableless
 # has_many :categories
  #accepts_nested_attributes_for :categories
  validate :sprawdz_ceny
  validate :sprawdz_daty
  validate :sprawdz_pagerank

  def sprawdz_pagerank
      errors.add(:uwaga, "dolny pułap pageranku musi być liczbą całkowitą z przedziału <1;10>") unless czy_pagerank_ok(pagerank_gte)
      errors.add(:uwaga, "górny pułap pageranku musi być liczbą całkowitą z przedziału <1;10>") unless czy_pagerank_ok(pagerank_lte)
  end

  def czy_pagerank_ok(pagerank_napis)
      return true if pagerank_napis == nil or pagerank_napis.length ==0
      return false if (pagerank_napis =~ /^[\d]+$/) == nil
      i = pagerank_napis.to_i
      return false if i > 10 or i < 1
      return true
  end

  def sprawdz_ceny
    errors.add(:uwaga, "dolny pułap przedziału cenowego musi być liczbą lub pozostawiony pusty ") unless current_price_gte == nil or current_price_gte.length == 0 or (current_price_gte =~ /^[\d]+(\.[\d]+){0,1}$/) != nil
    errors.add(:uwaga, "górny pułap przedziału cenowego musi być liczbą lub pozostawiony pusty ") unless current_price_lte == nil or current_price_lte.length == 0 or (current_price_lte =~ /^[\d]+(\.[\d]+){0,1}$/) != nil
  end

  def sprawdz_daty
    errors.add(:uwaga, "dolny pułap przedziału czasowego dla końca aukcji musi być datą w formacie RRRR-MM-DD lub pozostawiony pusty !") unless czy_data_ok(auction_end_gte)
    errors.add(:uwaga, "górny pułap przedziału czasowego dla końca aukcji musi być datą w formacie RRRR-MM-DD lub pozostawiony pusty !") unless czy_data_ok(auction_end_lte)
    errors.add(:uwaga, "dolny pułap przedziału czasowego dla końca aukcji produktu musi być datą w formacie RRRR-MM-DD lub pozostawiony pusty !") unless czy_data_ok(auction_auction_end_gte)
    errors.add(:uwaga, "górny pułap przedziału czasowego dla końca aukcji produktu musi być datą w formacie RRRR-MM-DD lub pozostawiony pusty !") unless czy_data_ok(auction_auction_end_lte)

  end

  def czy_data_ok(data_napis)
    return true if data_napis == nil or data_napis.length ==0
    begin
      Date.strptime(data_napis, '%Y-%m-%d')
    rescue ArgumentError => e
      return false
    end
    return true
  end

 # validates_numericality_of :current_price_lte, :greater_than => 0
  column :pagerank_gte, :string
  column :pagerank_lte, :string
  column :users_daily_gte, :integer
  column :users_daily_lte, :integer  
  column :x_pos_gte, :integer
  column :x_pos_lte, :integer
  column :y_pos_gte, :integer
  column :y_pos_lte, :integer
  column :width_gte, :integer
  column :width_lte, :integer
  column :height_gte, :integer
  column :height_lte, :integer
  column :number_of_links_gte, :integer
  column :number_of_links_lte, :integer
  column :words_number_gte, :integer
  column :frequency_gte, :decimal, :precision => 5, :scale => 4
  column :frequency_lte, :decimal, :precision => 5, :scale => 4
  column :words_number_lte, :integer
  column :words_number_gte, :integer
  column :auction_auction_end_gte, :string
  column :auction_auction_end_lte, :string
  column :auction_end_gte, :string
  column :auction_end_lte, :string
  column :product_type, :string
  column :current_price_gte, :string
  column :current_price_lte, :string
  column :order_by, :string
  column :search_type, :string
  column :user_login_like, :string
  column :auction_activated, :boolean
  column :auction_not_expired, :boolean
  column :auction_opened, :string
  column :user_login_like, :string
  column :by_auctionable_type, :string
  column :auction_time_of_service_gte, :boolean
  column :auction_time_of_service_lte, :boolean
  @cats
  @conditions = {}
  @order = {}
  def categories_attributes=(atr)
    @cats = []
    @cats.push(atr)
  end

  def categories_attributes
    @cats
  end

  def search_categories=(atr)
    @cats = []
    @cats.push(atr)
  end

  def search_categories
    @cats
  end

  def conditions=(atr)
    @conditions = {}
    @conditions.merge(atr)
  end
  def order=(atr)
    @order = {}
    @order.merge(atr)
  end
  def order
    @order
  end
  
  def conditions
    @conditions
  end
  #@categories = Category.all#.map{|t| t.name}
  def categories=(cat)
  #  @categories = {} 
  # @categories.merge(cat)
  end
  def categories
    @cats
  end
end
