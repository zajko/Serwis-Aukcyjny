class ArchivalAuctionSearch < Tableless
 # has_many :categories
  #accepts_nested_attributes_for :categories
  validate :sprawdz_ceny
  validate :sprawdz_daty

  def sprawdz_ceny
    errors.add(:uwaga, "dolny pułap przedziału cenowego musi być liczbą lub pozostawiony pusty ") unless current_price_gte == nil or current_price_gte.length == 0 or (current_price_gte =~ /^[\d]+(\.[\d]+){0,1}$/) != nil
    errors.add(:uwaga, "górny pułap przedziału cenowego musi być liczbą lub pozostawiony pusty ") unless current_price_lte == nil or current_price_lte.length == 0 or (current_price_lte =~ /^[\d]+(\.[\d]+){0,1}$/) != nil
    return errors.count == 0
  end

  def sprawdz_daty
    errors.add(:uwaga, "dolny pułap przedziału czasowego dla końca aukcji musi być datą w formacie RRRR-MM-DD lub pozostawiony pusty !") unless czy_data_ok(auction_end_gte)
    errors.add(:uwaga, "górny pułap przedziału czasowego dla końca aukcji musi być datą w formacie RRRR-MM-DD lub pozostawiony pusty !") unless czy_data_ok(auction_end_lte)
    return errors.count == 0
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
  column :auction_end_gte, :string
  column :auction_end_lte, :string
  column :product_type, :string
  column :current_price_gte, :string
  column :current_price_lte, :string
  column :order_by, :string
  column :search_type, :string
  column :auction_activated, :boolean
  column :auction_not_expired, :boolean
  column :auction_opened, :string
  column :user_login_like, :string
  column :by_auctionable_type, :string
  column :auction_time_of_service_gte, :boolean
  column :auction_time_of_service_lte, :boolean
  column :archival_auction_owner_login_like, :string
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
