class SponsoredArticle < ActiveRecord::Base
  extend Searchable
  validates_uri_existence_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix,
 :message => "Format adresu jest niepoprawny lub taka strona nie istnieje (nie odpowiada)."
  has_one :auction, :as => :auctionable, :autosave => true, :dependent => :destroy
  has_many :categories, :through => :auction
  accepts_nested_attributes_for :auction, :allow_destroy => true
  attr_accessible :auction_attributes
  attr_accessible :url
  attr_accessible :pagerank
  attr_accessible :users_daily
  attr_accessible :words_number
  attr_accessible :number_of_links
  validates_numericality_of :number_of_links, :greater_than => 0, :message => "Liczba linków artykułu musi być większa od 0"
  validates_numericality_of :words_number, :greater_than => 0, :message => "Liczba słów artykułu musi być większa od 0"
  named_scope :active, :include => :auction, :condition => {'auctions.activated' => true }
  validate :check_before_update, :on => :update 
  def check_before_update
    if new_record?
      return true
    end
    @prev_stat = SponsoredArticle.find(id)
    errors.add( "Nie można zmienić pageranku") if @prev_stat.pagerank != pagerank
    errors.add( "Nie można zmienić adresu strony") if @prev_stat.url != url
    errors.add( "Nie można zmienić liczby dziennych użytkowników") if @prev_stat.users_daily != users_daily
    errors.add( "Nie można zmienić aukcji produktu") if @prev_stat.auction != auction
    if auction.bids.not_cancelled.count > 0
      errors.add( "Nie można zmienić liczby słów artykułu gdy są nieanulowane oferty") if @prev_stat.words_number != words_number
      errors.add( "Nie można zmienić liczby linków w artykule gdy są nieanulowane oferty") if @prev_stat.number_of_links != number_of_links 
    end
    return errors.count == 0
  end
  
  named_scope :activated, { :joins => :auction, :conditions => { "auctions.activated" => true }}
  named_scope :order_scope , lambda{ |scope|
  { :order => scope }
  }
  
  named_scope :order_auction_scope , lambda{ |scope|
  { :conditions => "sponsored_articles.id=sponsored_articles.id", :joins => :auction, :order => scope }
  }
  named_scope :by_auctions_id, lambda{ |ids|    
    {
      :include => :auction,
      :conditions => ["auction.id IN (?)", ids]#.map(&:name)]
    }
   }
  named_scope :by_categories_id, lambda{ |*categories|
    {
      #:select => "DISTINCT sponsored_articles.*",
      :joins => "INNER JOIN auctions as A ON A.auctionable_type = 'SponsoredArticle' AND A.auctionable_id = sponsored_articles.id INNER JOIN auctions_categories AS AC ON A.id = AC.auction_id INNER JOIN categories ON categories.id = AC.category_id",
      :conditions => ["categories.id IN (?)", categories]
    }
  }
  
   def polish_name
    "Artykuł sponsorowany"
  end

def save
    errors.add( "Nie można utworzyć banneru bez aukcji.") if auction == nil

    if(errors.count == 0)
      return super
    else
      return false
    end
  end
end
