#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class BidTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  should_have_named_scope :by_date, :order => "created_at DESC"
  should_have_named_scope :not_cancelled, :conditions => { :cancelled => false}
  should_have_named_scope :cancelled, :conditions => { :cancelled => true}
  should_have_named_scope :by_offered_price, :order => "offered_price DESC, created_at ASC"
  should_have_named_scope :by_created_at_asc, :order => "created_at ASC"
  should_have_named_scope :by_created_at_desc, :order => "created_at DESC"

  def test_create_bid
    banner = create_auction_banner()
#      dodaje oferty do aukcji
    bid = Bid.new
    auction = banner.auction
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages
  end

  def test_update_auction_price
    banner = create_auction_banner()
#      dodaje oferty do aukcji
    bid = Bid.new
    auction = banner.auction
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages
    
    assert_equal 1, auction.bids.not_cancelled.count
    bid.update_auction_price
    assert_equal auction.minimal_price, auction.current_price
  end

  def test_ask_for_cancell
    banner = create_auction_banner()
#      dodaje oferty do aukcji
    bid = Bid.new
    auction = banner.auction
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages

    assert !bid.asking_for_cancellation
    bid.ask_for_cancell(nil)
    assert !bid.asking_for_cancellation
    assert_match(/Musisz być zalogowany żeby anulować swoje aukcje/, bid.errors.on_base)

    bid = Bid.last
    user2 = users(:jarek2)
    assert_not_nil user2
    assert !bid.asking_for_cancellation
    bid.ask_for_cancell(user2)
    assert !bid.asking_for_cancellation
    assert_match(/Tylko użytkownik, który złożył ofertę może poprosić o jej anulowanie/, bid.errors.on_base)

    bid = Bid.last
    user2 = bid.user
    assert_not_nil user2
    assert !bid.asking_for_cancellation
    bid.ask_for_cancell(user2)
    assert bid.asking_for_cancellation
  end

  def test_owner_of_auction_cant_bid
    banner = create_auction_banner()
#      dodaje oferty do aukcji
    bid = Bid.new
    auction = banner.auction
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = auction.user.id
    auction.activated=true
    auction.save


    assert !bid.save, bid.errors.full_messages
    assert_match(/Właściciel aukcji nie może licytować swojej aukcji/, bid.errors.on_base)
  end

#  def cancell_bid(cancelling_user, decision = false)
#      if ! decision
#        decision = false
#      end
#      if(cancelling_user.id == auction.user.id or cancelling_user.has_role?(:admin) or cancelling_user.has_role?(:superuser))
#        update_attribute :cancelled, decision
#        update_attribute :asking_for_cancellation, false
#        #TODO Może by tak przenieść do innej tabeli ?
#      else
#        errors.add_to_base("Tylko właściciel aukcji i administratorzy mogą anulować oferty aukcji")
#      end
#  end

  def test_cancell_bid
     banner = create_auction_banner()
#      dodaje oferty do aukcji
    bid = Bid.new
    auction = banner.auction
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages

    bid = Bid.last
    bid.cancelled = false
    assert !bid.cancelled
    asking_for_cancellation = bid.asking_for_cancellation
    bid.cancell_bid(users(:jarek2), false)
    assert !bid.cancelled
    assert_equal asking_for_cancellation, bid.asking_for_cancellation
    assert_match(/Tylko właściciel aukcji i administratorzy mogą anulować oferty aukcji/, bid.errors.on_base)

    bid = Bid.last
    bid.cancelled = false
    assert !bid.cancelled
    asking_for_cancellation = bid.asking_for_cancellation
    bid.cancell_bid(auction.user, false)
    assert !bid.cancelled
    assert_equal asking_for_cancellation, bid.asking_for_cancellation
    assert_nil bid.errors.on_base

    bid = Bid.last
    bid.cancelled = false
    assert !bid.cancelled
    bid.cancell_bid(auction.user, true)
    assert bid.cancelled
    assert_equal false, bid.asking_for_cancellation
    assert_nil bid.errors.on_base

    bid = Bid.last
    bid.cancelled = false
    assert !bid.cancelled
    user  = users(:jarek2)
    user.has_role!(:superuser)
    bid.cancell_bid(user, true)
    assert bid.cancelled
    assert_equal false, bid.asking_for_cancellation
    assert_nil bid.errors.on_base

    bid = Bid.last
    bid.cancelled = false
    assert !bid.cancelled
    user  = users(:jarek2)
    user.has_role!(:admin)
    bid.cancell_bid(user, true)
    assert bid.cancelled
    assert_equal false, bid.asking_for_cancellation
    assert_nil bid.errors.on_base
  end

#  def test_update_auction_time
#    banner = create_auction_banner()
##      dodaje oferty do aukcji
#    bid = Bid.new
#    auction = banner.auction
#    bid.auction_id=auction.id
#    bid.offered_price=1000
#    bid.user_id = users(:jarek1)
#    auction.activated=true
#    auction.start = Date.today()+1.days
#    auction.auction_end = Date.today()+10.days
#    auction.save
#    assert bid.save, bid.errors.full_messages
#
#    bid.update_auction_time
#    assert_equal auction.auction_end, bid.auction.auction_end
#  end

  def test_offered_price_meets_minimal
    banner = create_auction_banner()
#      dodaje oferty do aukcji
    bid = Bid.new
    auction = banner.auction
    auction.minimal_price = 10
    bid.auction_id=auction.id
    bid.offered_price=9
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.start = Date.today()+1.days
    auction.auction_end = Date.today()+10.days
    auction.save
    assert !bid.offered_price_meets_minimal
    assert_match(/Musisz zalicytować przynajmniej*/, bid.errors.on_base)
    assert !bid.save, bid.errors.full_messages

    bid.offered_price=15
    assert bid.offered_price_meets_minimal
    assert bid.save, bid.errors.full_messages
  end

#def check_before_update
#    if new_record?
#      return true
#    end
#    @prev_stat = Bid.find(id)
##    kod Kuby !!!!!!!!!
##    if !@prev_stat
##      errors.add(:s, "Taki rekord nie istnieje w bazie")
##      return false
##    end
#    errors.add(:s, "Nie można zmienić aukcji oferty") if @prev_stat.auction != auction
#    errors.add(:s, "Nie można zmienić użytkownika oferty") if @prev_stat.user != user
#    errors.add(:s, "Nie można zmienić kwoty, na którą została wystawiona oferta") if @prev_stat.offered_price != offered_price
#  end
  def test_uppdate
    banner = create_auction_banner()
#      dodaje oferty do aukcji
    bid = Bid.new
    auction = banner.auction
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.start = Date.today()+1.days
    auction.auction_end = Date.today()+10.days
    auction.save
    assert bid.save, bid.errors.full_messages

#    uppdate
     auction2 = Auction.new
      user = users(:user_not_active)
      assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
      auction2.user_id = user.id
      auction2.start = Date.today()+1.days
      auction2.auction_end=Date.today()+2.days
      auction2.activated = true
      auction2.auctionable_id = banner.id
      auction2.auctionable_type = "Banner"
      assert auction2.save, auction2.errors.full_messages

    bid = Bid.last
    bid.offered_price=100000
    assert !bid.save
    assert_match(/Nie można zmienić kwoty, na którą została wystawiona oferta/, bid.errors.on(:s))

    bid = Bid.last
    bid.user = users(:jarek2)
    assert !bid.save
    assert_match(/Nie można zmienić użytkownika oferty/, bid.errors.on(:s))
    
    bid = Bid.last
    bid.auction = auction2
    assert !bid.save
    assert_match(/Nie można zmienić aukcji oferty/, bid.errors.on(:s))

  end


  test "the truth" do
    assert true
  end

  protected
    def create_auction_banner()
      assert_difference 'Banner.count' do
      banner = Banner.new
      banner.url = 'http://www.o2.pl'
      banner.pagerank = 2
      banner.users_daily =100
      banner.width = 100
      banner.height = 200
      banner.x_pos = 50
      banner.y_pos =50
      banner.frequency = 0.5
      assert banner.valid?
      assert banner.save, banner.errors.full_messages
      #    dodaje aucje do banner
      auction = Auction.new
      user = users(:user_not_active)
      assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
      auction.user_id = user.id
      auction.start = Date.today()+1.days
      auction.auction_end=Date.today()+2.days
      auction.activated = true
      auction.auctionable_id = banner.id
      auction.auctionable_type = "Banner"
      assert auction.save, auction.errors.full_messages
    end
    Banner.last
  end

end
