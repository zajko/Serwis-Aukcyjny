class Bid < ActiveRecord::Base
  validates_numericality_of :offered_price, :greater_than => 0
  validates_presence_of :user
  validates_presence_of :auction, :counter_cache => false
  validate :buy_now_can_sell_limited, :message => "Niestety, na tej aukcji nie ma już więcej produktów do kupienia"
  validate :offered_price_meets_minimal, :message => "Musisz zalicytować najmniej minimalną cenę licytacji" 
  validate :can_bid_open_auctions #, :message => "Niestety, ta aukcja już się zakończyła"
  validate :can_bid_activated_auctions
  validate :owner_of_auction_cant_bid
  validate :check_before_update
  belongs_to :user#, :dependent => :destroy
  belongs_to :auction#, :dependent => :destroy
  named_scope :by_date, :order => "created_at DESC"
  named_scope :not_cancelled, :conditions => { :cancelled => false}
  named_scope :cancelled, :conditions => { :cancelled => true}
  named_scope :by_offered_price, :order => "offered_price DESC, created_at ASC"
  named_scope :by_created_at_asc, :order => "created_at ASC"
  named_scope :by_created_at_desc, :order => "created_at DESC"
  def save
    errors.add(:s, "Musi być zdefiniowany właściciel oferty") if user == nil
    errors.add(:s, "Musi być zdefiniowana aukcja na którą wystawiono oferŧę") if auction == nil
    errors.add(:s, "Aukcja, w której próbujesz wziąć udział ma charakter kup-teraz. Możesz złożyć ofertę tylko na ustaloną przez sprzedawcę cenę.") if auction and auction.buy_now_price > 0 and  auction.buy_now_price != offered_price

    if(errors.count == 0)
      return super
    else
      return false
    end
  end
  def check_before_update
    if new_record?
      return true
    end
    @prev_stat = Bid.find(id)
    errors.add(:s, "Nie można zmienić aukcji oferty") if @prev_stat.auction != auction
    errors.add(:s, "Nie można zmienić użytkownika oferty") if @prev_stat.user != user
    errors.add(:s, "Nie można zmienić kwoty, na którą została wystawiona oferta") if @prev_stat.offered_price != offered_price
  end
  
  def update_auction_price
    auction.current_price = auction.calculate_current_price
  end
  acts_as_authorization_object
  
  def ask_for_cancell(user)
    if user == nil
       errors.add_to_base("Musisz być zalogowany żeby anulować swoje aukcje") 
    else
      if user.id == self.user.id
        self.update_attribute :asking_for_cancellation, true
        #TODO Zrob powiadomienie wlasciciela aukcji
      else
        errors.add_to_base("Tylko użytkownik, który złożył ofertę może poprosić o jej anulowanie")
      end
    end
  end
  
  def owner_of_auction_cant_bid
      errors.add_to_base("Właściciel aukcji nie może licytować swojej aukcji") if user_id == auction.user.id
  end
  
  def cancell_bid(cancelling_user, decision = false)
      if ! decision
        decision = false
      end
      if(cancelling_user.id == auction.user.id or cancelling_user.has_role?(:admin) or cancelling_user.has_role?(:superuser))
        if update_attribute(:cancelled, decision) and update_attribute(:asking_for_cancellation, false)
          return true
        end
        #TODO Może by tak przenieść do innej tabeli ?
      else
        errors.add_to_base("Tylko właściciel aukcji i administratorzy mogą anulować oferty aukcji")
        return false
      end
  end
  
  def buy_now_can_sell_limited
    if auction.buy_now_price > 0
     errors.add_to_base("Niestety, na tej aukcji nie ma już więcej produktów do kupienia") unless auction.bids.not_cancelled.count < auction.number_of_products
   else
     return true
   end
  end
  def inform_interesants
    #TODO Powiadom właściciela o złożonej ofercie
    #TODO Jeżeli jest kupt_teraz, powiadom kupującego o danych sprzedającego 
  end
  
  def can_bid_open_auctions
    errors.add_to_base("Niestety, ta aukcja już się skończyła") if auction.auction_end <= Time.now
  end
  def can_bid_activated_auctions
    errors.add_to_base("Niestety, ta aukcja nie została jeszcze aktywowana") unless auction.activated
  end
#  def update_auction_time
#    Auction.transaction do
#      #a = Auction.find(self.auction_id)
#      if (auction.auction_end - created_at <= @@minimal_end_of_auction_interval)
#        t = Time.now.advance(:seconds => @@minimal_end_of_auction_interval)
#        #TODO zastanowic sie nad localtimem - trzeba poprawic tak zeby wszedzie sie wyswietlal i dodawal localtime !
#        if auction.update_attribute :auction_end, t
#
#        else
#          raise "Serious error !" #Tu sa nie przelewki, nie powinno nigdy tu wejsc...
#        end
#      end
#    end
#  end
  def offered_price_meets_minimal
    a = Auction.find(self.auction_id)
    minimal = a.minimal_bid
    if self.offered_price.to_f < a.minimal_bid.to_f
      errors.add_to_base("Musisz zalicytować przynajmniej " + a.minimal_bid.to_s)
      return false
    end
    return true
  end
end
