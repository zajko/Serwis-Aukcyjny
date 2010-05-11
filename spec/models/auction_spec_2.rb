require File.dirname(__FILE__) + '/../spec_helper'

describe Auction do
  fixtures :auctions, :site_links, :banners, :users, :pop_ups, :sponsored_articles, :bids
  before(:each) do
  end

  context "#ssociations" do
    it { should belong_to(:user) }
    it { should have_one(:charge) }
    it { should belong_to(:auctionable) }
    it { should have_many(:bids) }
    it { should have_and_belong_to_many(:observees) }
    it { should have_and_belong_to_many(:categories) }
  end


  it "shouldn`t allow user change" do
    a = auctions(:auction_1)
    u = users(:user_3)
    a.user=u
    a.save
    a.errors.count.should > 0
  end

  it "should save when properly loaded" do
    a = auctions(:auction_3)
    a.save.should == true
  end

  it "shouldn`t allow product change" do
    a = auctions(:auction_1)
    p = site_links(:site_link_1)
    if a.auctionable == p then
      p = site_links(:site_link_2)
    end
    a.auctionable = p
    a.save
    a.errors.count.should > 0
  end

  it "shouldn`t allow change of end date to the past" do
    a = auctions(:auction_1)
    a.auction_end = Time.now - 10.days
    a.save.should == false
  end

  it "shouldn`t allow change of end date when closed" do
    a = auctions(:closed_auction)
    a.auction_end = Time.now + 10.days
    a.save.should == false
  end

  it "should allow change of end date when no bids" do
    a = auctions(:buy_now_auction)
    a.auction_end = Time.now + 10.days
    a.save.should == true
  end

  it "shouldn't allow end date change when having bids " do
    a = auctions(:auction_1)
    a.auction_end = Time.now + 10.days
    a.save
    if a.bids.not_cancelled.count == 0
      a.errors.count.should == 0
    else
      a.errors.count.should > 0
    end
  end

  it "shouldn't allow buy now price change when having bids " do
    a = auctions(:auction_1)
    a.buy_now_price = a.buy_now_price + 10
    a.save
    if a.bids.not_cancelled.count == 0
      a.errors.count.should == 0
    else
      a.errors.count.should > 0
    end
  end

  it "shouldn't allow minimal price change when having bids " do
    a = auctions(:auction_1)
    a.buy_now_price = a.minimal_price + 10
    a.save
    if a.bids.not_cancelled.count == 0
      a.errors.count.should == 0
    else
      a.errors.count.should > 0
    end
  end

  it "shouldn't allow token change" do
    a = auctions(:auction_1)
    a.activation_token = "siabadaba" + (a.activation_token == nil ? "" : a.activation_token)
    a.save
    a.errors.count.should > 0
  end

  it "should calculate winning prices" do
    a = auctions(:auction_50)
    b = a.winningPrices()
    b.should include(a.calculate_current_price)
  end

  it "should actualize current price by minimal bid difference" do
    a = auctions(:auction_50)    
    if a.bids.not_cancelled.count > 0 then
      a.bids.not_cancelled.map{|x| x.offered_price}.should include(a.calculate_current_price)
      a.bids.not_cancelled.map{|x| x.offered_price}.sort.reverse.second.should == a.calculate_current_price
    else
      a.current_price.should = 0
    end
  end

end
