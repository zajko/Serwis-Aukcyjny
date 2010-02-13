#require 'Date'
class Auction < ActiveRecord::Base
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :observees, :class_name =>"User", :autosave => true#, :readonly => true
  has_one :charge, :as => :chargeable
  acts_as_authorization_object
  #has_many :auctions_categories
  has_many :bids, :dependent => :destroy
  belongs_to :user, :class_name => 'User', :foreign_key => "user_id" 
  belongs_to :auctionable, :polymorphic => true, :dependent => :destroy
  named_scope :active, :conditions => { :activated => true}
  named_scope :categorised, :joins => :categories, :select => 'Distinct post.*'
  named_scope :expired, :conditions => 'now() - auction_end > INTERVAL \'10 minutes\' '
  accepts_nested_attributes_for :user
  before_save :assign_roles
  
  validate :check_before_update, :on => :update
  accepts_nested_attributes_for :categories
  attr_accessible :category_ids
  attr_accessible :categories
  attr_accessible :auction_end
  attr_accessible :start
  attr_accessible :minimal_price
  attr_accessible :buy_now_price
  attr_accessible :minimal_bidding_difference
  attr_accessible :activation_token
  attr_accessible :user_attributes
  attr_accessible :user
  
  validates_presence_of :user_id, :message => "BŁĄD ! nie da się stworzyć aukcji bez właściciela" 
  validates_presence_of :start, :auction_end
  validate :start_must_be_after_today, :message => "Aukcja musi zacząć się najwcześniej od jutra"
  validate :start_must_be_before_end, :message => "Początek aukcji musi być przed jej końcem"
  validates_numericality_of :buy_now_price, :greater_than_or_equal_to => 0
  validates_numericality_of :minimal_price, :greater_than_or_equal_to => 0
  validate :limited_bid_count_if_buy_now_auction, :message => "Nie można już złożyc oferty na tą aukcję"
 # before_destroy :destroy_check
  
  def destroy
    if(destroy_check)
     super
   else
     false
    end
  end
  
  def destroy_check    
    if ApplicationController.get_static_user and (ApplicationController.get_static_user.has_role?(:admin) || ApplicationController.get_static_user.has_role?(:superuser))
      return true
    end
    if ApplicationController.get_static_user and user.id != ApplicationController.get_static_user.id
      errors.add("Nie możesz usunąć aukcję, która nie należy do ciebie !")
      return false
    end
    if ApplicationController.get_static_user and bids and bids.not_cancelled.count > 0
      errors.add("Nie możesz usunąć aukcję, która ma złożone oferty !")
      return false
    end
    
    return true
  end
  acts_as_authorization_object
  
  def check_before_update
    if new_record? || id == nil
      return true
    end
#    kod Kuby!!!!!!!!!
    @prev_stat = Auction.find(id)
    if !@prev_stat
      errors.add(:s, "Taki rekord nie istnieje w bazie")
      return false
    end
    errors.add(:s, "Koniec aukcji może być zmieniony tylko na datę późniejszą niż dzisiaj") if auction_end < Date.today
    errors.add(:s, "Nie można zmienić właściciela aukcji") if @prev_stat.user_id != user_id
    errors.add(:s, "Nie można zmienić tokenu aukcji") if @prev_stat.activation_token != activation_token
    errors.add(:s, "Nie można zmienić produktu aukcji") if @prev_stat.auctionable_type != auctionable_type or @prev_stat.auctionable_id != auctionable_id
    if bids.not_cancelled.count > 0
      errors.add(:s, "Nie można zmniejszyć liczby wystawionych przedmiotów gdy są nieanulowane aukcje") if @prev_stat.number_of_products > number_of_products
      errors.add(:s, "Nie można zmienić ceny kup teraz gdy są nieanulowane aukcje") if @prev_stat.buy_now_price != buy_now_price
      errors.add(:s, "Nie można zmienić ceny minimalnej gdy są nieanulowane aukcje") if @prev_stat.minimal_price != minimal_price
      #      kod Kuby!!!!!!!!!!
      errors.add(:s, "Nie można przenieść końca aukcji gdy są nieanulowane aukcje") if @prev_stat.auction_end != auction_end
    end
    return errors.count == 0
  end
   def start_must_be_before_end      
     errors.add(:s, "Pole początek aukcji musi być wypełnione datą conajmniej o jeden dzień wcześniejszą niż koniec aukcji") if
        id == nil and (start.blank? or self.start >= self.auction_end) #(self.start.year() * 1000 + self.start.month() * 100 +self.start.day()) >= (self.auction_end.year() * 1000 + self.auction_end.month() * 10 +self.auction_end.day())
    true 
   end
  
  def limited_bid_count_if_buy_now_auction
    bids.not_cancelled.count - 1 <= number_of_products
  end
  
  def notifyAuctionWinners
    raise "Not implemented yet"
  end
  
  def notifyAuctionWinner(user)
    raise "Not implemented yet"
  end
  
   def buy_now_price_null_or_numerical
    #     kod Kuby!!!!!!!!!!
#     if !buy_now_price
#       return true
#     else
       return  buy_now_price.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true unless buy_now_price.class == Fixnum
#     end
   end
   named_scope :activated, :conditions => { :activated => true }
   named_scope :by_type, lambda{ |type|
    {
      :conditions => ["auctions.auctionable_type = (?)", type]
    }
   }
   
#   named_scope :by_categories, lambda{ |*categories|
#    {
#      :include => :categories,
#      :conditions => ["categories.id IN (?)", categories.map(&:id)]
#    }
#   }
   
   named_scope :by_auctionable_type, lambda{ |type|
    {
      :conditions => ["activated = (?) AND auctionable_type =(?)", true, type]
    }
   }
   
   named_scope :by_categories_name, lambda{ |*categories|
    {
      :include => :categories, 
      :conditions => ["categories.name IN (?)", categories]#.map(&:name)]
    }
   }
   
   named_scope :by_categories_id, lambda{ |*categories|
    {
      :include => :categories, 
      :conditions => ["categories.id IN (?)", categories]#.map(&:name)]
    }
   }
   
   named_scope :by_auctionable_id, lambda{ |ids|    
    {
      :conditions => ["auctions.auctionable_id IN (?)", ids]#.map(&:name)]
    }
   }
   
   named_scope :minimum_days_until_end_of_auction, lambda{ |*days|
    {
      :conditions => ["auctions.auction_end - (?) >= INTERVAL '(?) days'",Time.now, days]#.map(&:name)]
    }
   }
   
   named_scope :maximum_days_until_end_of_auction, lambda{ |*days|
    {
      :conditions => ["auctions.auction_end - (?) <= INTERVAL '(?) days'",Time.now, days]#.map(&:name)]
    }
   }
  named_scope :order_scope , lambda{ |scope|
  { :order => scope }
  }
   def buy_now?
     return buy_now_price > 0
   end
   
   def close()
    #raise "Not implemented yet"
    #TODO Powiadamianie licytatorów o wygranej
    
    #TODO Powiadamianie użytkownika o zakończeniu aukcji 
    
   end
   
   def assign_roles
    # puts "BLA"     
#     if(new_record?)
#        if(auctionable)
#          auctionable.save
#          self.auctionable_type = auctionable.class
#          self.auctionable_id = auctionable.id
#        end
#      end
   end
  
  def start_must_be_after_today
    a = Time.now
      errors.add(:s, "The start of an auction can`t be dated in the past") if new_record? and !start.blank? and (start.year() * 1000 + start.month() * 100 + start.day() ) < (a.year() * 1000 + a.month() *100 + a.day())
  end
  
  def user_attributes=(attributes)
    self.user = User.find(attributes)
    #auction.auctionable = self
    #raise auction.auctionable.pagerank.to_s
  end

  def minimal_bid
    if buy_now_price > 0
      buy_now_price
    else
      calculate_current_price + minimal_bidding_difference
    end
  end
  
  def calculate_current_price
    if buy_now_price > 0
      return buy_now_price
    end
      if(bids.not_cancelled.count > 0) 
        t = bids.not_cancelled.by_offered_price.all
        if(t.count == 1)
          minimal_price #+ minimal_bidding_difference  
        else
          t.fetch(1).offered_price 
        end
      else
        minimal_price  
      end
  end
  
  def bid()
    
  end
  
  def self.prepare_search_scopes(params = {})
    raise "Nie powinieneś korzystać z tej metody NO MORE !"
   # product_scope = Kernel.const_get(product_type.classify).prepare_search_scopes(params)
    #products_all = product_scope.all
    
    #scope.search.find(:include => product_scope, :conditions => {})
    #Auction.auctionable_pagerank_gte(0)
    
    
    #raise scope.size.to_s
    #scope = scope.by_auctionable_type(params[:product_type].classify)
    
    #TODO ACHTUNG ! powyższe dwie linijki, jeżeli nie będą mogły sparsować pól minimum_days_until... i maximum_days_until... to po prostu je zignorują bez feedbacku do użyszkodnika
    
#    scope = Auction.search(:auctionable_type => params[:product_type].classify, :activated => true)
#    scope = scope.minimum_days_until_end_of_auction(params[:minimum_days_until_end_of_auction].to_i) if params[:minimum_days_until_end_of_auction].to_i > 0
#    scope = scope.maximum_days_until_end_of_auction(params[:maximum_days_until_end_of_auction].to_i) if params[:maximum_days_until_end_of_auction].to_i > 0
#    if(params != nil and params[:categories_attributes] != nil)
#      temp = params[:categories_attributes].map {|t| t.to_i}#.reject {|k, v| v.to_i == 0}.to_a.map{|k, v| k}
#      if(temp != nil && temp.size > 0)
#        scope = scope.by_categories_id(*temp)
#      end
#    end
#    if params[:order_by] && Auction.all.first.attributes.has_key? (params[:order_by].split(' ')[0])
#      scope = scope.order_scope( params[:order_by] ) 
#      elems = Kernel.const_get(params[:product_type].classify).prepare_search_scopes(params).all.map{|t| t.id}
#      scope = scope.by_auctionable_id(elems)
#      elems = scope.all.map {|t| t.auctionable }
#    else
#      elems = Kernel.const_get(params[:product_type].classify).prepare_search_scopes(params)
#      elems.by_auctions_id(scope.all.map{|t| t.id})
#      elems = elems.all
#    end
    
    
    
    
    #TODO to jest horrendalnie niewydajne... o ile w ogole bedzie dzialac
   #scope.order_by = :created_at
   #scope.order_as = "DESC"
    
    return elems




  end
  
  

end
