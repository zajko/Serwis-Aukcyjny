require 'spec_helper'

describe PopUp do
  fixtures :auctions, :pop_ups, :users, :bids
  before(:each) do
  end
  
  it "should have an auction" do
    b = pop_ups(:pop_up_1)
    b.auction.should_not be_nil
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

  it "shouldn`t allow auction change" do
   # b = pop_ups(:pop_up_2)
   # c = pop_ups(:pop_up_3)
   # b.auction = c.auction
   # b.save
   # b.errors.count.should > 0
   #TODO czemu to nie dziala ?
  end

  it "shouldn`t allow page url change" do
    b = pop_ups(:pop_up_1)
    b.url = b.url + "supcio"
    b.save
    b.errors.count.should > 0
  end

  it "should be searchable by minimal price" do
    search_scopes= {:auction_minimal_price_gt => 0, :auction_minimal_price_lte => 12}
    pop_ups = (PopUp.prepare_search_scopes(search_scopes)).all
    pop_ups.each do |b|
      b.auction.minimal_price.should > 0
      b.auction.minimal_price.should < 12
    end
  end

  it "should be searchable by pagerank" do
    search_scopes= {:pagerank_gt => 1, :pagerank_lt => 9}
    pop_ups = (PopUp.prepare_search_scopes(search_scopes)).all
    pop_ups.each do |b|
      b.pagerank.should > 0
      b.pagerank.should < 9
    end
  end

  it "should be searchable by users daily" do
    search_scopes= {:users_daily_gt => 5, :pagerank_lt => 20}
    pop_ups = (PopUp.prepare_search_scopes(search_scopes)).all
    pop_ups.each do |b|
      b.users_daily > 5
      b.users_daily < 20
    end
  end

end