require 'validates_uri_existance'
require 'application_controller.rb'
class SiteLink < ActiveRecord::Base
  extend Searchable
#  validates_uri_existence_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix,
# :message => "Format adresu jest niepoprawny lub taka strona nie istnieje (nie odpowiada)."
  has_one :auction, :as => :auctionable, :autosave => true, :dependent => :destroy
  has_many :categories, :through => :auction
  accepts_nested_attributes_for :auction, :allow_destroy => true
  attr_accessible :auction_attributes
  attr_accessible :url
  attr_accessible :pagerank
  attr_accessible :users_daily
  #attr_accessible :auction_attributes
  #attr_accessible :category_ids
  validate :check_before_update, :on => :update 
  def check_before_update
    if new_record?
      return true
    end
    @prev_stat = SiteLink.find(id)
#    kod Kuby!!!!!!!!!!
#    if !@prev_stat
#
#      errors.add(:s, "Taki rekord nie istnieje w bazie")
#      return false
#    end
    errors.add(:s, "Nie można zmienić pageranku") if @prev_stat.pagerank != pagerank
    errors.add(:s, "Nie można zmienić adresu strony") if @prev_stat.url != url
    errors.add(:s, "Nie można zmienić liczby dziennych użytkowników") if @prev_stat.users_daily != users_daily
    errors.add(:s, "Nie można zmienić aukcji produktu") if @prev_stat.auction != auction
    return errors.count == 0
  end
  
  named_scope :active, :include => :auction, :condition => {'auctions.activated' => true }
  #named_scope :auction, :include => :auction
  named_scope :activated, { :joins => :auction, :conditions => { "auctions.activated" => true }}
  named_scope :order_scope , lambda{ |scope|
  { :order => scope }
  }
  named_scope :order_by_auction, lambda{|scope|
  {
    :join => :auction,
    :order=> "auction."+scope
  }
  }
  
  def SiteLink.searchObject(params)
    #SiteLinkSearch.new(params)
  end
  named_scope :pagerank_gte, lambda{ |pagerank|
    {
      :conditions => ["site_links.pagerank >= (?)", pagerank]
    }
   } 
  named_scope :order_auction_scope , lambda{ |scope|
  { 
    :conditions => "site_links.id =site_links.id", :joins => :auction, :order => scope }
  }
  named_scope :by_auctions_id, lambda{ |ids|    
    {
      :include => :auction,
      :conditions => ["auction.id IN (?)", ids]#.map(&:name)]
    }
   }
  named_scope :by_categories_id, lambda{ |*categories|
    {
      :select => "site_links.*",
      :joins => "INNER JOIN auctions AS A ON auctionable_type = 'SiteLink' AND auctionable_id = site_links.id INNER JOIN auctions_categories AS AC ON A.id = AC.auction_id INNER JOIN categories ON categories.id = AC.category_id",
      :conditions => ["categories.id IN (?)", categories]
    }
  }
   named_scope :pagerank_lte, lambda{ |pagerank|
    {
      :conditions => ["site_links.pagerank <= (?)", pagerank]
    }
   }
   
   named_scope :users_daily_gte, lambda{ |users_daily|
    {
      :conditions => ["site_links.users_daily >= (?)", users_daily]
    }
   } 
   
   named_scope :users_daily_lte, lambda{ |users_daily|
    {
      :conditions => ["site_links.users_daily <= (?)", users_daily]
    }
   }
   named_scope :by_categories_name, lambda{ |*categories|
    {
      :include => :categories, 
      :conditions => ["categories.name IN (?)", categories]#.map(&:name)]
    }
   }
   named_scope :by_catss, lambda{ |*categories|
    {
      :include => :auction,       
      :conditions => ["auctions.auctionable_type = (?)", self.class.to_s]
    }
   }

  def polish_name
    "Link"
  end
   
end

class SiteLinkSearch < Tableless
 # has_many :categories
  #accepts_nested_attributes_for :categories
  
end
