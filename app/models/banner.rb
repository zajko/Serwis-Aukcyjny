require 'validates_uri_existance'
require 'tableless.rb'
class Banner < ActiveRecord::Base
	extend Searchable
  validates_uri_existence_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :message => "Format adresu jest niepoprawny lub taka strona nie istnieje (nie odpowiada)."
  has_one :auction, :as => :auctionable, :autosave => true, :dependent => :destroy
  has_many :auctions_categories, :through => :auction
  accepts_nested_attributes_for :auction, :allow_destroy => true
  validates_numericality_of :width, :greater_than => 0
  validates_numericality_of :height, :greater_than => 0
  validates_numericality_of :x_pos, :greater_than => 0
  validates_numericality_of :y_pos, :greater_than => 0
  validates_numericality_of :pagerank, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10
  validates_numericality_of :users_daily, :greater_than_or_equal_to => 0
  named_scope :activated, { :joins => :auction, :conditions => { "auctions.activated" => true }}
  validate :check_before_update, :on => :update
 
  

  def check_before_update
    if new_record?
      return true
    end
    @prev_stat = Banner.find(id)
    errors.add(:s, "Nie można zmienić pageranku") if @prev_stat.pagerank != pagerank
    errors.add(:s, "Nie można zmienić adresu strony") if @prev_stat.url != url
    errors.add(:s, "Nie można zmienić liczby dziennych użytkowników") if @prev_stat.users_daily != users_daily
    errors.add(:s, "Nie można zmienić aukcji produktu") if @prev_stat.auction != auction
    if auction.bids.not_cancelled.count > 0
      errors.add(:s, "Nie można zmienić wymiaru bannera gdy są nieanulowane oferty") if @prev_stat.width != width or @prev_stat.height != height
      errors.add(:s, "Nie można zmienić pozycji bannera gdy są nieanulowane oferty") if @prev_stat.y_pos != y_pos or @prev_stat.x_pos != x_pos
      errors.add(:s, "Nie można zmienić częstotliwości wyświetlania bannera gdy są nieanulowane oferty") if @prev_stat.frequency != frequency
    end
    return errors.count == 0
  end
  
  named_scope :order_scope , lambda{ |scope|
  { :order => scope }
  }
  
  named_scope :order_auction_scope , lambda{ |scope|
    {
      :conditions => "banners.id =banners.id", 
      :joins => :auction,
      :order => scope
    }
  }
  named_scope :by_auctions_id, lambda{ |ids|    
    {
      :conditions => ["auction.id IN (?)", ids]#.map(&:name)]
    }
   }
  named_scope :by_categories_id, lambda{ |*categories|
    {
     # :select => "DISTINCT banners.*",
      :joins => "INNER JOIN auctions AS A ON A.auctionable_type = 'Banner' AND A.auctionable_id = banners.id INNER JOIN auctions_categories AS AC ON A.id = AC.auction_id INNER JOIN categories ON categories.id = AC.category_id",
      :conditions => ["categories.id IN (?)", categories]
    }
  }

  def save()
    if(errors.count == 0)
      return super
    else
      return false
    end
  end
  
  def polish_name
    "Banner"
  end


end

