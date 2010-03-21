require 'spec_helper'

describe Bid do
  fixtures :auctions, :sponsored_articles, :banners, :pop_ups, :site_links, :users, :bids

  it "shouldn`t save without user" do
    b = Bid.new
    b.offered_price = 10000
    b.auction = auctions(:auction_1)
    b.user = nil
    b.bid_created_time=Time.now()
    b.save.should == false
  end

  it "shouldn`t save without auction" do
    b = Bid.new
    b.offered_price = 10000
    b.auction = nil
    b.user = users(:user_1)
    b.bid_created_time=Time.now()
    b.save.should == false
  end

  it "shouldn`t save when user is owner of auction" do
    b = Bid.new
    b.offered_price = 10000
    b.auction = auctions(:auction_3)
    b.user = b.auction.user
    b.bid_created_time=Time.now()
    b.save.should == false
  end

  it "shouldn`t be addable to not activated auction" do
    b = Bid.new
    b.offered_price = 10000
    b.auction = auctions(:not_activated_auction)
    b.user = users(:user_2)
    b.bid_created_time=Time.now()
    b.save.should == false
  end

  it "shouldn`t allow auction change" do
    b=bids(:bid_1_auction_1)
    b.auction = auctions(:auction_2)
    b.bid_created_time=Time.now()
    b.save.should == false
  end

  it "shouldn`t allow user change" do
    b=bids(:bid_1_auction_1)
    b.user = users(:user_2)
    b.bid_created_time=Time.now()
    b.save.should == false
  end

  it "shouldn`t allow offered price change" do
    b=bids(:bid_1_auction_1)
    b.offered_price = b.offered_price + 100
    b.save.should == false
  end

  it "shouldn`t allow to bid on closed auctions" do
    b=Bid.new
    b.auction=auctions(:closed_auction)
    b.offered_price =10000
    b.user=users(:user_2)
    b.bid_created_time=Time.now()
    b.save.should == false
  end

  it "shouldn`t add to buy now auction when with wrong offered price" do
    a = auctions(:buy_now_auction)
    b=Bid.new
    b.auction=a
    b.offered_price = a.buy_now_price + 30
    b.user = users(:user_2)
    b.bid_created_time=Time.now()
    b.save.should == false
  end

  it "should add to buy now auction when with correct offered price" do
    a = auctions(:buy_now_auction)
    b=Bid.new
    b.auction=a
    b.offered_price = a.buy_now_price
    b.user = users(:user_2)
    b.bid_created_time=Time.now()
    b.save.should == true
  end

  it "shouldn't be addable when not meeting minimal bidding price" do
    a = auctions(:auction_1)
    b=Bid.new
    b.auction=a
    b.offered_price = a.minimal_bid - 10 < 0 ? 0 : a.minimal_bid - 10
    b.user = users(:user_2)
    b.bid_created_time=Time.now()
    b.save.should == false
  end

  it "should be addable when meeting minimal bidding price" do
    a = auctions(:auction_1)
    b=Bid.new
    b.auction=a
    b.offered_price = a.minimal_bid + 10
    b.user = users(:user_2)
    b.bid_created_time=Time.now()
    b.save.should == true
  end

end