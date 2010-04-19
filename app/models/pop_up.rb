require 'validates_uri_existance'
require 'tableless.rb'
class PopUp < ActiveRecord::Base
  extend Searchable
  has_one :auction, :as => :auctionable, :autosave => true, :dependent => :destroy
  accepts_nested_attributes_for :auction, :allow_destroy => true
  validates_uri_existence_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :message => "Format adresu jest niepoprawny lub taka strona nie istnieje (nie odpowiada)."
  validates_presence_of :auction
  validates_numericality_of :frequency, :greater_than => 0, :less_than_or_equal => 1, :message => "Częstość pojawiania się okna pop-up musi być liczbą z przedziału (0, 1>"
  validates_numericality_of :width, :greater_than => 0
  validates_numericality_of :height, :greater_than => 0
  validates_numericality_of :pagerank, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10
  validates_numericality_of :users_daily, :greater_than_or_equal_to => 0
  accepts_nested_attributes_for :auction, :allow_destroy => true
  named_scope :activated, { :joins => :auction, :conditions => { "auctions.activated" => true }}
  
  validate :check_before_update, :on => :update 
  def check_before_update
    if new_record?
      return true
    end
    @prev_stat = PopUp.find(id)
    errors.add(:s, "Nie można zmienić pageranku") if @prev_stat.pagerank != pagerank
    errors.add(:s, "Nie można zmienić adresu strony") if @prev_stat.url != url
    errors.add(:s, "Nie można zmienić liczby dziennych użytkowników") if @prev_stat.users_daily != users_daily
    errors.add(:s, "Nie można zmienić aukcji produktu") if @prev_stat.auction != auction
    if auction.bids.not_cancelled.count > 0
      errors.add(:s, "Nie można zmienić wymiaru okna pop up gdy są nieanulowane oferty") if @prev_stat.width != width or @prev_stat.height != height
      errors.add(:s, "Nie można zmienić częstotliwości wyświetlania bannera gdy są nieanulowane oferty") if @prev_stat.frequency != frequency
    end
    return errors.count == 0
  end
  
  named_scope :by_auctions_id, lambda{ |ids|    
    {
      :include => :auction,
      :conditions => ["auction.id IN (?)", ids]#.map(&:name)]
    }
  }
  
  named_scope :order_auction_scope , lambda{ |scope|
  { :conditions => "banners.id =banners.id", :joins => :auction, :order => scope }
  }
  
  named_scope :by_categories_id, lambda{ |*categories|
    {
      :select => "pop_ups.*",
      :joins => "INNER JOIN auctions AS A ON auctionable_type = 'PopUp' AND auctionable_id = pop_ups.id INNER JOIN auctions_categories AS AC ON A.id = AC.auction_id INNER JOIN categories ON categories.id = AC.category_id",
      :conditions => ["categories.id IN (?)", categories]
    }
  }

  def save
    errors.add(:s, "Nie można utworzyć banneru bez aukcji.") if auction == nil

    if(errors.count == 0)
      return super
    else
      return false
    end
  end
  
  def polish_name
    "Pop up"
  end
end
