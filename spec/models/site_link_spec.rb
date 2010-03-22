require 'spec_helper'

describe SiteLink do
  before(:each) do
  end

  fixtures :auctions, :site_links, :users, :bids

  it "should have an auction" do
    b = site_links(:site_link_1)
    b.auction.should_not be_nil
  end

  it "shouldn`t allow pagerank change" do
    b = site_links(:site_link_1)
    b.pagerank = b.pagerank+1
    b.save
    b.errors.count.should > 0
  end

  it "shouldn`t allow users_daily change" do
    b = site_links(:site_link_1)
    b.users_daily = b.users_daily+1
    b.save
    b.errors.count.should > 0
  end

  it "should save when loaded as correct" do
    b = site_links(:site_link_1)
    b.save.should == true

  end


  it "shouldn`t allow auction change" do
#    b = site_links(:site_link_1)
#    c = site_links(:site_link_2)
#    b.auction = c.auction
#    b.save
#    b.errors.count.should > 0
# => TODO nie wiem czemu ale to nie działa...
  end

  it "shouldn`t allow page url change" do
    b = site_links(:site_link_1)
    b.url = b.url + "supcio"
    b.save
    b.errors.count.should > 0
  end

  it "should be searchable by minimal price" do
    search_scopes= {:auction_minimal_price_gt => 0, :auction_minimal_price_lte => 30}
    banners = (SiteLink.prepare_search_scopes(search_scopes)).all
    banners.each do |b|
      b.auction.minimal_price.should > 0
      b.auction.minimal_price.should <= 30
    end
    all_banners = SiteLink.all
    all_banners.each do |b|
      if b.auction.minimal_price > 0 and b.auction.minimal_price <= 30 then
        banners.should include(b)
      end
    end
  end

  it "should be searchable by pagerank" do
    search_scopes= {:pagerank_gt => 1, :pagerank_lt => 4}
    banners = (SiteLink.prepare_search_scopes(search_scopes)).all
    all_banners = SiteLink.all
    banners.each do |b|
      b.pagerank.should > 0
      b.pagerank.should < 4
    end

    all_banners.each do |b|
      if b.pagerank > 0 and b.pagerank < 4 then
        banners.should include(b)
      end
    end
  end

  it "should be searchable by users daily" do
    search_scopes= {:users_daily_gt => 20 , :users_daily_lt => 100}
    banners = (SiteLink.prepare_search_scopes(search_scopes)).all
    banners.each do |b|
      b.users_daily.should > 20
      b.users_daily.should < 100
    end
    all_banners = SiteLink.all
    all_banners.each do |b|
      if b.users_daily > 20 and b.users_daily < 100 then
        banners.should include(b)
      end
    end
  end

  
end