class Bid < ActiveRecord::Base
  validates_numericality_of :offered_price, :greater_than => 0
  validates_presence_of :user
  validates_presence_of :auction, :counter_cache => false
  validate :no_two_bids_from_same_user_in_row
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
    errors.add( "Musi być zdefiniowany właściciel oferty") if user == nil
    errors.add( "Musi być zdefiniowana aukcja na którą wystawiono oferŧę") if auction == nil
    errors.add( "Aukcja, w której próbujesz wziąć udział ma charakter kup-teraz. Możesz złożyć ofertę tylko na ustaloną przez sprzedawcę cenę.") if auction and auction.buy_now_price > 0 and  auction.buy_now_price != offered_price

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
    errors.add( "Nie można zmienić aukcji oferty") if @prev_stat.auction != auction
    errors.add( "Nie można zmienić użytkownika oferty") if @prev_stat.user != user
    errors.add( "Nie można zmienić kwoty, na którą została wystawiona oferta") if @prev_stat.offered_price != offered_price
  end
  def no_two_bids_from_same_user_in_row
    bids = auction.bids.not_cancelled.by_offered_price
    if bids.count > 0
      x = (bids.first.id == id or bids.first.user.id != user.id)
      errors.add( "Jesteś osobą, która akutalnie wygrywa. Nie możesz w tej chwili licytować") if !x
      return x
    else
      return true
    end
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
        self.asking_for_cancellation=true
        if !self.save
          x = ""
          self.errors.each do |e|
            x = x + "\n#{e}"
          end
          raise x
        end
       # self.update_attribute :asking_for_cancellation, true
        #TODO Zrob powiadomienie wlasciciela aukcji
      else
        errors.add_to_base("Tylko użytkownik, który złożył ofertę może poprosić o jej anulowanie")
      end
    end
  end
  
  def owner_of_auction_cant_bid
      errors.add_to_base("Właściciel aukcji nie może licytować swojej aukcji") if user_id == auction.user.id
  end

  def cancell_bid (decision = false)
    return false if auction.auction_end < Time.now()
    self.cancelled = decision
    self.asking_for_cancellation=false
    if self.save!
#    if update_attribute(:cancelled, decision) and update_attribute(:asking_for_cancellation, false)
          return true
    end
  end

  def buy_now_can_sell_limited
    if auction.buy_now_price > 0
     errors.add_to_base("Niestety, na tej aukcji nie ma już więcej produktów do kupienia") unless auction.bids.not_cancelled.count < auction.number_of_products or !new_record?
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

  def offered_price_meets_minimal
    if !self.new_record?
      raise "Z jakiegoś powodu baza utraciła wartość oferty o identyfikatorze : #{self.id}" if self.offered_price.nil?
      return true
    end
    a = Auction.find(self.auction_id)
    minimal = a.minimal_bid
    if self.offered_price.to_f < a.minimal_bid.to_f
      errors.add_to_base("Musisz zalicytować przynajmniej " + a.minimal_bid.to_s)
      return false
    end
    return true
  end
end
