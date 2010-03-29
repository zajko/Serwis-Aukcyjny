#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class PopUpTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  should_have_named_scope :activated, { :joins => :auction, :conditions => { "auctions.activated" => true }}
  should_have_named_scope 'by_auctions_id(1,2)', :include => :auction, :conditions => ["auction.id IN (?)", [1,2]]
  should_have_named_scope 'order_auction_scope("id desc")',:joins => :auction, :conditions => "banners.id =banners.id",  :order => "id desc"
  should_have_named_scope 'by_categories_id(1,2)', :select => "pop_ups.*",
      :joins => "INNER JOIN auctions AS A ON auctionable_type = 'PopUp' AND auctionable_id = pop_ups.id INNER JOIN auctions_categories AS AC ON A.id = AC.auction_id INNER JOIN categories ON categories.id = AC.category_id",
      :conditions => ["categories.id IN (?)", [1,2]]


  def test_create_new_pop_up
#    nowy PopUp
  assert_difference 'PopUp.count' do
    popUp = PopUp.new
    popUp.url = 'http://www.o2.pl'
    popUp.pagerank = 2
    popUp.users_daily =100
    popUp.width = 100
    popUp.height = 200
    popUp.frequency = 0.5
    assert popUp.valid?
    assert popUp.save, popUp.errors.full_messages
    #    dodaje aucje do popUp
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.auctionable_id = popUp.id
    auction.auctionable_type = "PopUp"
    assert auction.save, auction.errors.full_messages
    assert_equal 1, Auction.by_type("PopUp").count
  end
#    uppdate popUp
  assert_no_difference 'PopUp.count' do
    popUp = PopUp.last
    assert_not_nil popUp

    popUp.update_attributes(:pagerank=>10)
    assert_match(/Nie można zmienić pageranku/, popUp.errors.on(:s))
    popUp.save

    popUp = PopUp.last
    popUp.update_attributes(:url=>'http://www.google.pl')
    assert_match(/Nie można zmienić adresu strony/, popUp.errors.on(:s))
    popUp.save

    popUp = PopUp.last
    popUp.update_attributes(:users_daily=>100000)
    assert_match(/Nie można zmienić liczby dziennych użytkowników/, popUp.errors.on(:s))
    popUp.save

#    popUp = PopUp.last
#    auction2 = Auction.new
#    user = users(:user_not_active)
#    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
#    auction2.user_id = user.id
#    auction2.start = Date.today()+1.days
#    auction2.auction_end=Date.today()+2.days
#    auction2.activated = true
#    auction2.auctionable_id = popUp.id
#    auction2.auctionable_type = "PopUp"
#    assert auction2.save, auction2.errors.full_messages
#    popUp = PopUp.last
#    popUp.update_attributes(:auction=>auction2)
#    assert_match(/Nie można zmienić aukcji produktu/, popUp.errors.on(:s))
#    popUp.save


      #    dodaje bid
    bid = Bid.new
    auction = popUp.auction
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages
    

#    dodaje oferty do aukcji
    bid = Bid.new
    auction = popUp.auction
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages

    popUp = PopUp.last
    popUp.update_attributes(:width=>100000)
    assert_match(/Nie można zmienić wymiaru okna pop up gdy są nieanulowane oferty/, popUp.errors.on(:s))
    popUp.save

    popUp = PopUp.last
    popUp.update_attributes(:frequency=>0.4)
    assert_match(/Nie można zmienić częstotliwości wyświetlania bannera gdy są nieanulowane oferty/, popUp.errors.on(:s))
    popUp.save
  end
  end


def test_prepare_search_scopes
  scope = PopUp.scoped({})
  scope = scope.activated
  assert_equal scope, PopUp.prepare_search_scopes(nil)

  popUp = PopUp.new
  
    popUp.url = 'http://www.o2.pl'
    popUp.pagerank = 2
    popUp.users_daily =100
    popUp.width = 100
    popUp.height = 200
    popUp.frequency = 0.5
    assert popUp.valid?
    assert popUp.save, popUp.errors.full_messages
    #    dodaje aucje do popUp
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
#    auction.auctionable_id = popUp.id
#    auction.auctionable_type = "PopUp"
    auction.auctionable = popUp
    assert auction.save, auction.errors.full_messages
    
    assert PopUp.prepare_search_scopes({:pagerank_gte=>1, :pagerank_lte=>10, :users_daily_gte=>10, :users_daily_lte=>100,
    :width_gte=>1, :width_lte=>1000, :height_gte=>1, :height_lte=>1000, :frequency_gte=>0.1, :frequency_lte=>1.0}).count>0
  
end

  test "the truth" do
    assert true
  end
end
