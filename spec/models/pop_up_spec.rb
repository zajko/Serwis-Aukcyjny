require 'spec_helper'

describe PopUp do
  fixtures :auctions, :pop_ups, :users, :bids

  it { should allow_value("http://www.o2.pl").for(:url) }
  it { should_not allow_value("mielonka mielonka mielonka").for(:url) }
  it { should allow_value(5).for(:pagerank)}
  it { should allow_value(0).for(:pagerank)}
  it { should_not allow_value(-1).for(:pagerank)}
  it { should_not allow_value(11).for(:pagerank)}
  it { should_not allow_value("a").for(:pagerank)}

  it { should allow_value(0).for(:users_daily)}
  it { should allow_value(1000).for(:users_daily)}
  it { should_not allow_value(-40).for(:users_daily)}
  it { should_not allow_value("SS").for(:users_daily)}
  
  it { should allow_value(100).for(:width)}
  it { should allow_value(100).for(:height)}

  it { should_not allow_value(0).for(:width)}
  it { should_not allow_value(0).for(:height)}
  it { should_not allow_value("a").for(:width)}
  it { should_not allow_value("a").for(:height)}

  context "#ssociations" do
    it { should have_one(:auction) }
    
  end

  it "should nigga pliz" do
    b = pop_ups(:pop_up_1)
    PopUp.find(b.id)
  end

  it "shouldn`t allow pagerank change" do
    b = pop_ups(:pop_up_1)
    b.pagerank = b.pagerank+1
    b.save
    b.errors.count.should > 0
  end

  it "shouldn`t allow users_daily change" do
    b = pop_ups(:pop_up_1)
    b.users_daily = b.users_daily+1
    b.save
    b.errors.count.should > 0
  end

  it "should save when loaded as correct" do
    b = pop_ups(:pop_up_1)
    b.save.should == true
  end

  it "shouldn`t allow position and dimensions change when valid bids" do
    b = pop_ups(:pop_up_1)
    if(b.auction.bids.not_cancelled.count > 0) then
      b.height = b.height+1
      b.width = b.width+1
      b.save
      b.errors.count.should > 0
    end
  end

  it "shouldn`t allow page url change" do
    b = pop_ups(:pop_up_1)
    b.url = b.url + "supcio"
    b.save
    b.errors.count.should > 0
  end

  it "should be searchable by minimal price" do
    search_scopes= {:auction_minimal_price_gt => 0, :auction_minimal_price_lte => 30}
    banners = (PopUp.prepare_search_scopes(search_scopes)).all
    banners.each do |b|
      b.auction.minimal_price.should > 0
      b.auction.minimal_price.should <= 30
    end
    all_banners = PopUp.all
    all_banners.each do |b|
      if b.auction.minimal_price > 0 and b.auction.minimal_price <= 30 then
        banners.should include(b)
      end
    end
  end

  it "should be searchable by pagerank" do
    search_scopes= {:pagerank_gt => 1, :pagerank_lt => 4}
    banners = (PopUp.prepare_search_scopes(search_scopes)).all
    all_banners = PopUp.all
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
    banners = (PopUp.prepare_search_scopes(search_scopes)).all
    banners.each do |b|
      b.users_daily.should > 20
      b.users_daily.should < 100
    end
    all_banners = PopUp.all
    all_banners.each do |b|
      if b.users_daily > 20 and b.users_daily < 100 then
        banners.should include(b)
      end
    end
  end

end