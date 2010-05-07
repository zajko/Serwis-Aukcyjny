#require 'Date'
class Auction < ActiveRecord::Base
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :observees, :class_name =>"User", :autosave => true#, :readonly => true
  has_one :charge, :as => :chargeable
  acts_as_authorization_object
  has_many :bids#, :dependent => :destroy
  belongs_to :user, :class_name => 'User', :foreign_key => "user_id" 
  belongs_to :auctionable, :polymorphic => true, :dependent => :destroy
  named_scope :active, :conditions => { :activated => true}
  named_scope :categorised, :joins => :categories, :select => 'Distinct post.*'
  named_scope :expired, :conditions => 'now() - auction_end > INTERVAL \'10 minutes\' '
  accepts_nested_attributes_for :user
  #before_save :assign_roles
  
  validate :check_before_update, :on => :update
  #accepts_nested_attributes_for :categories
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
  
  validates_presence_of :user_id, :message => "Nie da się utworzyć aukcji bez właściciela."
  validates_presence_of :start, :auction_end
 # validates_presence_of :auctionable, :message => "Nie da się zapisać aukcji bez produktu."
  validate :start_must_be_after_today, :message => "Aukcja musi zacząć się najwcześniej od jutra"
  validate :start_must_be_before_end, :message => "Początek aukcji musi być przed jej końcem"
  validates_numericality_of :buy_now_price, :greater_than_or_equal_to => 0
  validates_numericality_of :minimal_price, :greater_than_or_equal_to => 0
  
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
#    if ApplicationController.get_static_user and user.id != ApplicationController.get_static_user.id
#      errors.add("Nie możesz usunąć aukcję, która nie należy do ciebie !")
#      return false
#    end
#ApplicationController.get_static_user and
    if auction_end > Time.now() and bids and bids.not_cancelled.count > 0
      errors.add("Nie możesz usunąć aukcję, która ma złożone oferty !")
      return false
    end
    
    return true
  end
  acts_as_authorization_object

  def notify_about_auction_prize_change!
      observees.each do |observee|
        #TODO zastanowic sie jak to rozwiazac, to bedzie zajmowalo DUZO czasu
      end
      overbidded_user = bids.not_cancelled.by_offered_price.second if bids.not_cancelled.count > 1
      Notifier.deliver_auction_bids_change_notification_to_overbidded_user(self, overbidded_user)
  end
  
  def check_before_update
    if new_record? || id == nil
      return true
    end
    @prev_stat = Auction.find(id)
    if !@prev_stat
      errors.add(:s, "Taki rekord nie istnieje w bazie")
      return false
    end
    errors.add(:s, "Koniec aukcji może być zmieniony tylko na datę późniejszą niż dzisiaj") if auction_end < Date.today
    errors.add(:s, "Nie można zmienić właściciela aukcji") if @prev_stat.user_id != user_id
    errors.add(:s, "Nie można zmienić tokenu aukcji") if @prev_stat.activation_token != activation_token
    errors.add(:s, "Nie można zmienić produktu aukcji") if @prev_stat.auctionable_type != auctionable_type or @prev_stat.auctionable_id != auctionable_id
    errors.add(:s, "Nie można zmienić daty końca aukcji zakończonej aukcji") if @prev_stat.auction_end < Time.now and @prev_stat.auction_end != auction_end
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
       return  buy_now_price.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true unless buy_now_price.class == Fixnum
   end
   named_scope :activated, :conditions => { :activated => true }
   named_scope :by_type, lambda{ |type|
    {
      :conditions => ["auctions.auctionable_type = (?)", type]
    }
   }
   
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
   
   named_scope :by_auctionable_id, lambda{ |*ids|
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
     raise "Ta metoda jest przestarzała, w przyszłych wersjach zostanie usunięta"
   end
   
  def winningBids
    ret = []
    bids_not_cancelled = bids.not_cancelled.count
    number = number_of_products > bids_not_cancelled ? bids_not_cancelled : number_of_products
    bidsArr = bids.not_cancelled.by_date.all
    number.times do |i|
        ret << bidsArr[i]
    end
    return bidsArr
  end

  def winningPrices
    @current_price = calculate_current_price
    ret = winningBids()
    ret = ret.map{|x| x.offered_price}
    if buy_now_price == 0
      if ret.length > 1
        ret[0] = ret[1] + minimal_bidding_difference
      else
        if ret.length > 0
          ret[0] = @current_price#minimal_price #+ minimal_bidding_difference
        else
          ret[0] = 0
        end
      end
    end
    return ret
  end
  
  def start_must_be_after_today
    a = Time.now
      errors.add(:s, "The start of an auction can`t be dated in the past") if new_record? and !start.blank? and (start.year() * 1000 + start.month() * 100 + start.day() ) < (a.year() * 1000 + a.month() *100 + a.day())
  end
  
  def user_attributes=(attributes)
    self.user = User.find(attributes)
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

  def actualize_current_price()
    @current_price = calculate_current_price
  end
  
  def self.prepare_search_scopes(params = {})
    raise "Nie powinieneś korzystać z tej metody NO MORE ! Ma ona zostać usunięta"
  end

  def deliver_auction_activation_instructions!
    Notifier.deliver_auction_activation_instructions(self)
  end

  def notify_auction_owner!(winningBids, charge)
    Notifier.deliver_auction_end_notification(self, winningBids, charge)
  end

  def notify_auction_winners!
    if bids.not_cancelled.count == 0
      return
    end
    
    first = bids.not_cancelled.by_offered_price.first 
    if first == nil
      raise "BŁĄD ! skoro model.bids.not_cancelled.count > 0 to jakim cudem first == nil ?"
    end
    price = 0;
    w = winningBids.each do |b|
      if(first.id == b.id)
        b.offered_price = current_price
      end
        deliver_auction_win_notification(b.user, b.offered_price)
        price += b.offered_price
    end
    notify_auction_owner!(w, price)
  end

  def deliver_auction_win_notification(user, price)
    Notifier.deliver_auction_win_notification(self, user, price)
  end

  def activate
    if auction_end < Time.now
      errors.add(:s, "Aukcja już się zakończyła.")
      return false
    end
    if activated
      return true
    end
    if !activated
        s ||= auctionable.url
        begin
          
          open(s) {
            |f|
            if f.string.contains(@activation_token)
              @activated = true
              save
              #TODO Dodanie aukcji do kolejki w demonie zamykającym aukcje
              return true
            end
          }
        rescue
          errors.add(:s, "Podany w aukcji url jest niepoprawny lub nie odpowiada.")
          return false
        end
    else
      return true
    end
  end

end
