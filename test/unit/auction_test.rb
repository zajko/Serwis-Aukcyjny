#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class AuctionTest < ActiveSupport::TestCase
  fixtures :auctions, :users, :banners

  should_have_named_scope :active,  :conditions => { :activated => true}
  should_have_named_scope :categorised, :joins => :categories, :select => 'Distinct post.*'
  should_have_named_scope :expired, :conditions => 'now() - auction_end > INTERVAL \'10 minutes\' '
  should_have_named_scope :activated, :conditions => { :activated => true }
  should_have_named_scope 'by_type("Banner")', :conditions => ["auctions.auctionable_type = (?)", "Banner"]
#  should_have_named_scope 'by_categories(1)', :conditions => ["categories.id IN (?)", [1]]
  #should_have_named_scope 'by_auctionable_type(true,"Banner")', :conditions => ["activated = (?) AND auctionable_type =(?)", true, [true,"Banner"]]
  #should_have_named_scope 'by_auctionable_type(false,"Banner")', :conditions => ["activated = (?) AND auctionable_type =(?)", true, [false,"Banner"]]
  should_have_named_scope 'by_categories_name("sport")',:include => :categories, :conditions => ["categories.name IN (?)", ["sport"]]
  should_have_named_scope 'by_categories_name("sport","muzyka")',:include => :categories, :conditions => ["categories.name IN (?)", ["sport","muzyka"]]
  should_have_named_scope 'by_categories_id(1,2)',:include => :categories, :conditions => ["categories.id IN (?)", [1,2]]
  should_have_named_scope 'by_auctionable_id(1,2,3)', :conditions => ["auctions.auctionable_id IN (?)", [1,2,3]]
  #should_have_named_scope 'minimum_days_until_end_of_auction(2)',  :conditions => ["auctions.auction_end - (?) >= INTERVAL '(?) days'",Time.now,2]
  #should_have_named_scope 'maximum_days_until_end_of_auction(2)', :conditions => ["auctions.auction_end - (?) <= INTERVAL '(?) days'",Time.now, 2]
  should_have_named_scope 'order_scope("desc")', :order => "desc"

  def test_truth
    assert true
  end

  def test_create
    auction = Auction.new
    assert_not_nil(auction, "object not created")
  end

  def test_invalid_with_empty_attributes
    auction = Auction.new
    assert !auction.valid?, auction.errors.full_messages
  end

  def test_aukcja_bez_wlasciciela
    auction = Auction.new
    assert !auction.valid?, auction.errors.full_messages
    assert !auction.user_id.present?
    assert_match(/BŁĄD ! nie da się stworzyć aukcji bez właściciela/, auction.errors.on(:user_id))

    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}

    auction.user_id = user.id
    assert auction.user_id.present?
  end

  def test_before_update_check_no_user_change
    a = auctions(:auction_1)
    u = users(:user_3)
    a.user=u
    a.save
    assert a.errors.count > 0
  end

  def test_before_update_check_no_product_change
    a = auctions(:auction_1)
    p = site_links(:site_link_1)
    if a.auctionable == p then
      p = site_links(:site_link_2)
    end
    a.auctionable = p
    a.save
    assert a.errors.count > 0
  end

  def test_before_update_check_no_past_end_date
    a = auctions(:auction_1)
    a.auction_end = Time.now - 10.days
    a.save
    assert a.errors.count > 0
  end
  
  def test_before_update_check_no_date_change_when_bids
    a = auctions(:auction_1)
    a.auction_end = Time.now + 10.days
    a.save
    assert a.bids.not_cancelled.count == 0 or a.errors.count > 0
  end

  def test_before_update_check_no_buy_now_price_change_when_bids
    a = auctions(:auction_1)
    a.buy_now_price = a.buy_now_price + 10
    a.save
    assert a.bids.not_cancelled.count == 0 or a.errors.count > 0
  end

  def test_before_update_check_no_minimal_price_change_when_bids
    a = auctions(:auction_2)
    a.minimal_price = a.minimal_price + 10
    a.save
    assert a.bids.not_cancelled.count == 0 or a.errors.count > 0
  end

  
  def test_before_update_check_no_token_change
    a = auctions(:auction_1)
    a.activation_token = "siabadaba" + (a.activation_token == nil ? "" : a.activation_token)
    a.save
    assert a.errors.count > 0
  end


  def test_auction_start_and_end_auction
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    assert !auction.valid?, auction.errors.full_messages
    assert !auction.start.present?
    auction.start = Date.today()
    auction.auction_end = Date.today()
    assert_not_nil auction.errors.full_messages
    assert !auction.valid?, auction.errors.full_messages
    auction.start = Date.today()+1.days
    assert !auction.valid?, auction.errors.full_messages
    auction.auction_end=Date.today()+2.days
    assert auction.valid?, auction.errors.full_messages
  end

  def test_save
#    assert_difference("auctions.count", +1) do
      #assert_equal 0, auctions.count
      auction = Auction.new
      user = users(:user_not_active)
      assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
      auction.user_id = user.id
      auction.start = Date.today()+1.days
      auction.auction_end=Date.today()+2.days
      auction.buy_now_price=10;
      auction.current_price=10;
      auction.minimal_bidding_difference=5;
      auction.minimal_price=10;
      assert auction.save, auction.errors.full_messages
#    end
  end

  def test_auction_uppdate
    assert_difference 'Auction.count' do
      auction = Auction.new
      user = users(:user_not_active)
      assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
      auction.user_id = user.id
      auction.start = Date.today()+1.days
      auction.auction_end=Date.today()+2.days
      auction.buy_now_price=10
      auction.current_price=10
      auction.minimal_bidding_difference=5
      auction.minimal_price=10
      auction.number_of_products = 20
      assert auction.save, auction.errors.full_messages
    end
    auction = Auction.last
    auction.auction_end=(Date.today()-1.days)
    auction.save
    assert_match(/Koniec aukcji może być zmieniony tylko na datę późniejszą niż dzisiaj/, auction.errors.on(:s))

    auction = Auction.last
    auction.update_attributes(:auction_end=>(Date.today()+1.days))
    assert_nil auction.errors.on(:s)
    auction.save

#    auction = Auction.last
#    auction.update_attributes(:auctionable_type=>'site_link')
#    assert_match(/Nie można zmienić właściciela aukcji/, auction.errors.on(:s))
#    auction.save

    auction = Auction.last
    auction.update_attributes(:user=>users(:jarek1))
    assert_match(/Nie można zmienić właściciela aukcji/, auction.errors.on(:s))
    auction.save

    auction = Auction.last
    auction.update_attributes(:activation_token=>"token")
    assert_match(/Nie można zmienić tokenu aukcji/, auction.errors.on(:s))
    auction.save
    
#    auction.update_attributes(:auctionable_id=>2)
#    assert_match (/Nie można zmienić produktu aukcji/, auction.errors.on(:s))

    auction = Auction.last
    auction.update_attributes(:number_of_products=>10)
#    assert_equal 10, auction.number_of_products
    assert_no_match(/Nie można zmniejszyć liczby wystawionych przedmiotów gdy są nieanulowane aukcje/, auction.errors.on(:s))
    auction.save

#    dodaje bits
    assert_difference 'Bid.count' do
    auction = Auction.last
    bid = Bid.new
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    assert !bid.save, bid.errors.full_messages
#    aktywacja aukcji
    auction = Auction.last
    auction = Auction.last
    bid = Bid.new
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages
    end

    auction = Auction.last
    auction.buy_now_price=10000000
    assert !auction.save
    assert_match(/Nie można zmienić ceny kup teraz gdy są nieanulowane aukcje/, auction.errors.on(:s))

    auction = Auction.last
    auction.minimal_price=10000000
    assert !auction.save
    assert_match(/Nie można zmienić ceny minimalnej gdy są nieanulowane aukcje/, auction.errors.on(:s))

    auction = Auction.last
#    assert false, auction.number_of_products
    auction.number_of_products=1
    assert_equal 1, auction.number_of_products
    assert !auction.save
    assert_match(/Nie można zmniejszyć liczby wystawionych przedmiotów gdy są nieanulowane aukcje/, auction.errors.on(:s))

    auction = Auction.last
    auction.auction_end=Date.today+2.days
    assert !auction.save
    assert_match(/Nie można przenieść końca aukcji gdy są nieanulowane aukcje/, auction.errors.on(:s))

  end


  def test_create_auction_banner
    assert_difference 'Auction.count' do      
    assert_equal 2, Banner.count
    banner = banners(:one)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    assert auction.save, auction.errors.full_messages
    
    assert_equal 2, Banner.count
    assert !auction.new_record?, "#{auction.errors.full_messages.to_sentence}"
    end
  end

  def test_destroy_auction_banner
    assert_no_difference 'Auction.count' do
#    tworze aukcje
    assert_equal 2, Banner.count
    banner = banners(:one)

    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    assert auction.save, auction.errors.full_messages

    assert_equal 2, Banner.count
    assert !auction.new_record?, "#{auction.errors.full_messages.to_sentence}"
    Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(self)
#    usuwanie
    auction.destroy
    end
  end

  def test_add_bid

    banner = banners(:one)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    assert auction.save, auction.errors.full_messages
    #    dodaje bits
    assert_difference 'Bid.count' do
    auction = Auction.last
    bid = Bid.new
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1).id
    assert !bid.save, bid.errors.full_messages
#    aktywacja aukcji
    auction = Auction.last
    auction = Auction.last
    bid = Bid.new
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1).id
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages
    end
  end

  def test_notifyAuctionWinners
    banner = banners(:one)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    assert auction.save, auction.errors.full_messages
    
    assert_raise(RuntimeError) {auction.notifyAuctionWinners}
  end

  def test_notifyAuctionWinnerUser
    banner = banners(:one)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    assert auction.save, auction.errors.full_messages
    
    assert_raise(RuntimeError) {auction.notifyAuctionWinner(users(:jarek1))}
  end

  def test_buy_now_price_null_or_numerical
    banner = banners(:one)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.buy_now_price = nil
    assert !auction.save, auction.errors.full_messages
    auction.buy_now_price = 0.0
    assert auction.save, auction.errors.full_messages

    assert auction.buy_now_price_null_or_numerical
  end

  def test_calculate_current_price_buy_now_auction
    banner = banners(:one)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.buy_now_price = 100.0
    auction.minimal_price = 10.0
    assert_equal true, auction.buy_now?
    assert auction.save, auction.errors.full_messages

    assert 100.0, auction.calculate_current_price
  end

   def test_calculate_current_price_buy_bid_auction
    banner = banners(:one)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.buy_now_price = 0.0
    auction.minimal_price = 10.0
    assert auction.save, auction.errors.full_messages

    assert 10.0, auction.calculate_current_price
  end

   def test_calculate_current_price_buy_bid_auction_more_than_one_bid
    banner = banners(:one)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.buy_now_price = 0.0
    assert_equal false, auction.buy_now?
    auction.minimal_price = 10.0
    assert auction.save, auction.errors.full_messages

    assert 10.0, auction.minimal_bid
    assert 10.0, auction.calculate_current_price
    assert_difference 'Bid.count', 2 do
    auction = Auction.last
    bid = Bid.new
    bid.auction_id=auction.id
    assert 10.0, auction.minimal_bid
    assert 10.0, auction.calculate_current_price
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages
    assert 15.0, auction.minimal_bid
    assert 15.0, auction.calculate_current_price
    bid = Bid.new
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek2)
    assert bid.save, bid.errors.full_messages
    assert 20.0, auction.minimal_bid
    assert 20.0, auction.calculate_current_price
    end
  end

  def test_user_attributes
    banner = banners(:one)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.buy_now_price = 0.0
    auction.minimal_price = 10.0
    assert auction.save, auction.errors.full_messages

    auction.user_attributes=(users(:jarek1).id)
  end

  def test_prepare_search_scopes
    assert_raise(RuntimeError) {Auction.prepare_search_scopes()}
  end

  def test_named_scope_by_type
    assert_equal 0, Auction.by_type("Banner").count
    banner = banners(:one)
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
    assert_equal 1, Auction.by_type("Banner").count
  end

#  def test_named_scope_by_categories
#    category = categories(:one)
#    assert_equal 0, Auction.by_categories(category.id).count
#
#    banner = banners(:one)
#    auction = Auction.new
#    user = users(:user_not_active)
#    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
#    auction.user_id = user.id
#    auction.start = Date.today()+1.days
#    auction.auction_end=Date.today()+2.days
#    auction.activated = true
#    auction.auctionable_id = banner.id
#    auction.auctionable_type = "Banner"
#    auction.categories<<category
#    assert auction.save, auction.errors.full_messages
#    assert_equal 1, Auction.by_categories(category.id).count, auction.categories.first
#
#  end
#
#  def test_named_scope_by_auctionable_type
#    assert false, Auction.auctionable_type("banner").count
#  end
#
#  def test_named_scope_by_categories_name
#    assert false, Auction.by_categories_name("banner").count
#  end
#
#  def test_named_scope_by_categories_id
#    assert false, Auction.by_categories_id("banner").count
#  end
#
#  def test_named_scope_by_auctionable_id
#    assert false, Auction.by_auctionable_id("banner").count
#  end
#
#  def test_named_scope_minimum_days_until_end_of_auction
#    assert false, Auction.minimum_days_until_end_of_auction("banner").count
#  end
#
#  def test_named_scope_maximum_days_until_end_of_auction
#    assert false, Auction.maximum_days_until_end_of_auction("banner").count
#  end
#
#  def test_named_scope_order_scope
#    assert false, Auction.order_scope("banner").count
#  end
#
#  def test_named_scope_by_auctionable_type
#    assert false, Auction.by_auctionable_type("banner").count
#  end
end
