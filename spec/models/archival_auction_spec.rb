# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../spec_helper'

describe ArchivalAuction do
  fixtures :auctions, :site_links, :banners, :users, :pop_ups, :sponsored_articles, :bids

  def create_auction
    a = auctions(:auction_1)
    p = site_links(:site_link_1)
    if a.auctionable == p then
      p = site_links(:site_link_2)
    end
    a.auctionable = p
    a.save
    a
  end

  def create_archival_auction
    auction = create_auction
    archival_auction = ArchivalAuction.new
    archival_auction=ArchivalAuction.copy_attributes_between_models(auction, archival_auction)
    archival_auction.auction_created_time = auction.created_at
    archival_auction.id = auction.id
    archival_auction.archival_auction_owner = auction.user
    archival_auction.save
    archival_auction
  end
#  context "#powiazania" do
#   it { should have_many(:archival_bids) }
#   it { should have_one(:charge) }
#   it { should belongs_to(:archival_auction_owner) }
#end

  it "should allow copy attributes between models without save archival auction" do
    auction = create_auction
    archival_auction = ArchivalAuction.new
    archival_auction=ArchivalAuction.copy_attributes_between_models(auction, archival_auction)
    archival_auction.id.should be_nil
  end
  it "should allow copy attributes between models after that correct save" do
    auction = create_auction
    archival_auction = ArchivalAuction.new
    archival_auction=ArchivalAuction.copy_attributes_between_models(auction, archival_auction)
    archival_auction.id.should be_nil
    archival_auction.auction_created_time = auction.created_at
    archival_auction.id = auction.id
    archival_auction.archival_auction_owner = auction.user
    archival_auction.save.should be_true
  end
  it "shouldn't allow change attributes in old archival auction" do
    archival_auction = create_archival_auction
    auction = create_auction
    auction.current_price = archival_auction.current_price
    archival_auction.current_price = 1.0
    (archival_auction.current_price != auction.current_price).should be_true
    archival_auction=ArchivalAuction.copy_attributes_between_models(auction, archival_auction, {:dont_overwrite=>'true'})
    (auction.current_price != archival_auction.current_price).should be_true
  end
  it "should allow change attributes in old archival auction" do
    archival_auction = create_archival_auction
    auction = create_auction
    auction.current_price = archival_auction.current_price
    archival_auction.current_price = 1.0
    (archival_auction.current_price != auction.current_price).should be_true
    archival_auction=ArchivalAuction.copy_attributes_between_models(auction, archival_auction)
    (auction.current_price == archival_auction.current_price).should be_true
  end
  it "should allow change attributes in old archival auction" do
    archival_auction = create_archival_auction
    auction = create_auction
    auction.current_price = archival_auction.current_price
    archival_auction.current_price = 1.0
    (archival_auction.current_price != auction.current_price).should be_true
    archival_auction=ArchivalAuction.copy_attributes_between_models(auction, archival_auction, {:dont_overwrite=>'false'})
   pending do (auction.current_price == archival_auction.current_price).should be_true end
  end
  it "shouldn't copy current_price" do
    auction = create_auction
    archival_auction = ArchivalAuction.new
    archival_auction=ArchivalAuction.copy_attributes_between_models(auction, archival_auction, {:except_list=>[:current_price]})
    archival_auction.current_price.should be_nil
  end


  it "should move auction to archival auction" do
    auction = create_auction
    archival_auction = ArchivalAuction.from_auction(auction)
    archival_auction.save.should be_true
  end
  
  it "should move auction to archivel auction when having bids" do
    auction = auctions(:auction_1)
    auction.bids.count.should > 0
    archive_auction = ArchivalAuction.from_auction(auction)
    archive_auction.save.should be_true
    archive_auction.archival_bids.count.should == auction.bids.count
  end

end

