# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../spec_helper'

describe ArchivalBid do
  fixtures :auctions, :site_links, :banners, :users, :pop_ups, :sponsored_articles, :bids

  def create_archival_bid
    b=bids(:bid_1_auction_1)
    archival_bid = ArchivalBid.new
    archival_bid = ArchivalBid.copy_attributes_between_models(b, archival_bid)
    archival_bid.archival_bid_owner = b.user
    archival_bid.bid_created_time = b.created_at
    archival_bid.archival_biddable = b.auction
    archival_bid.save
    archival_bid
  end
#  context "#powiazania" do
#   it { should belongs_to(:archival_bid_owner) }
#   it { should belongs_to(:archival_biddable) }
#  end


  it "should copy attribites between the models" do
    b=bids(:bid_1_auction_1)
    archival_bid = ArchivalBid.new
    archival_bid = ArchivalBid.copy_attributes_between_models(b, archival_bid)
    archival_bid.archival_bid_owner = b.user
    archival_bid.bid_created_time = b.created_at
    archival_bid.archival_biddable = b.auction
    archival_bid.save.should be_true
  end

  it "should not overwrite old attributes" do
    b=bids(:bid_1_auction_1)
    archival_bid = create_archival_bid
    archival_bid.offered_price = b.offered_price
    archival_bid.offered_price = 1099
    (archival_bid.offered_price != b.offered_price).should be_true
    archival_bid = ArchivalBid.copy_attributes_between_models(b, archival_bid, {:dont_overwrite=>'true'})
    (archival_bid.offered_price != b.offered_price).should be_true
  end

  it "should overwrite old attributes" do
    b=bids(:bid_1_auction_1)
    archival_bid = create_archival_bid
    archival_bid.offered_price = b.offered_price
    archival_bid.offered_price = 1099
    (archival_bid.offered_price != b.offered_price).should be_true
    archival_bid = ArchivalBid.copy_attributes_between_models(b, archival_bid, {:dont_overwrite=>'false'})
    pending do (archival_bid.offered_price == b.offered_price).should be_true end
  end

  it "should overwrite old attributes without overwrite param" do
    b=bids(:bid_1_auction_1)
    archival_bid = create_archival_bid
    archival_bid.offered_price = b.offered_price
    archival_bid.offered_price = 1099
    (archival_bid.offered_price != b.offered_price).should be_true
    archival_bid = ArchivalBid.copy_attributes_between_models(b, archival_bid)
    (archival_bid.offered_price == b.offered_price).should be_true
  end

  it "shouldn't copy offered_prive" do
    b=bids(:bid_1_auction_1)
    archival_bid = ArchivalBid.new
    archival_bid = ArchivalBid.copy_attributes_between_models(b, archival_bid, {:except_list=>[:offered_price]})
    archival_bid.offered_price.should be_nil
  end

   it "should move bid to archival bid" do
    b=bids(:bid_1_auction_1)
    archival_bid = ArchivalBid.from_bid(b)
    archival_bid.save.should be_true
  end
end

