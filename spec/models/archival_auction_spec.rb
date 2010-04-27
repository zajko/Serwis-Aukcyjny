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

  it "should preserve Auction's id number" do
    auction = auctions(:auction_1)
    auction.bids.each do |b| #usuwamy oferty jesli sa jakies - po to zeby dalo sie zarchiwizowac aukcje
      b.destroy
    end
    auction.destroy.should_not== false
    archival = ArchivalAuction.find_by_id(auction.id)
    archival.id.should==auction.id
  end

#  it "shouldn't allow attributes changing in old archival auction" do #Jarku, ja nie wiem co chciales tym przetestowac
#    archival_auction = create_archival_auction
#    auction = create_auction
#    auction.current_price = archival_auction.current_price
#    archival_auction.current_price = 1.0
#    (archival_auction.current_price != auction.current_price).should be_true
#    archival_auction=ArchivalAuction.copy_attributes_between_models(auction, archival_auction, {:dont_overwrite=>'true'})
#    (auction.current_price != archival_auction.current_price).should be_true
#  end
  
  it "shouldn't copy current_price" do
    auction = create_auction
    archival_auction = ArchivalAuction.new
    archival_auction=ArchivalAuction.copy_attributes_between_models(auction, archival_auction, {:except_list=>[:current_price]})
    archival_auction.current_price.should be_nil
  end

  it "shouldn't archivize auctions which have not ended and have valid bids" do
    auction = auctions(:auction_1)
    if auction.auction_end < Time.now() or auction.bids.not_cancelled.count == 0
      raise "Źle przygotowana aukcja testowa"
    end
    
    auction.destroy.should == false
  end

  it "should move auction to archival auction when having no bids" do
    auction = auctions(:auction_1)
    auction.bids.each do |b|
      b.destroy
    end
    auction.destroy.should_not==false
  end

end

