# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../spec_helper'

describe AuctionObserver do
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

  it "should move auction to archival auction" do
    auction = create_auction
    Auction.find(auction.id).should eql(auction)
    lambda {ArchivalAuction.find(auction.id) }.should raise_error()
    auction.destroy
#    nie ma już aukcji w tabeli aukcje
    lambda {Auction.find(auction.id) }.should raise_error()
#    pojawila sie nowa aucja w tabeli archivalne aukcje
    (ArchivalAuction.find(auction.id)!=nil ).should be_true
  end

  it "should move auction with bids to archival auction" do
    auction = auctions(:auction_1)
    auction.bids.count.should > 0
    Auction.find(auction.id).should eql(auction)
    lambda {ArchivalAuction.find(auction.id) }.should raise_error()

    auction.destroy
#    nie ma już aukcji w tabeli aukcje
    lambda {Auction.find(auction.id) }.should raise_error()
#    pojawila sie nowa aucja w tabeli archivalne aukcje
    (ArchivalAuction.find(auction.id)!=nil ).should be_true
    ArchivalAuction.find(auction.id).archival_bids.count.should > 0
  end
  it "should move auction with payment to archival auction"


  #  def before_destroy(model)
  #    a = ArchivalAuction.from_auction(model)
  #    a.save
  #  end
end

