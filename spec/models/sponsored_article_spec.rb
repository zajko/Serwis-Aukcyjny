require File.dirname(__FILE__) + '/../spec_helper'

describe SponsoredArticle do
  fixtures :auctions, :sponsored_articles, :users, :bids


  context "#ssociations" do
    it { should have_one(:auction) }
    
  end
  
  it "should have an auction" do
    b = sponsored_articles(:sponsored_article_1)
    b.auction.should_not be_nil
  end

  it "shouldn`t allow pagerank change" do
    b = sponsored_articles(:sponsored_article_1)
    b.pagerank = b.pagerank+1
    b.save
    b.errors.count.should > 0
  end

  it "shouldn`t allow users_daily change" do
    b = sponsored_articles(:sponsored_article_1)
    b.users_daily = b.users_daily+1
    b.save
    b.errors.count.should > 0
  end

  it "should save when loaded as correct" do
    b = sponsored_articles(:sponsored_article_1)
    b.save.should == true

  end

  it "shouldn`t allow word count change when valid bids" do
    b = sponsored_articles(:sponsored_article_1)
    if(b.auction.bids.not_cancelled.count > 0) then
      b.words_number = b.words_number + 1
      b.save
      b.errors.count.should > 0
    end
  end

  it "shouldn`t allow links count change when valid bids" do
    b = sponsored_articles(:sponsored_article_1)
    if(b.auction.bids.not_cancelled.count > 0) then
      b.number_of_links = b.number_of_links + 1
      b.save
      b.errors.count.should > 0
    end
  end

  it "shouldn`t allow auction change" do
#    b = sponsored_articles(:sponsored_article_1)
#    c = sponsored_articles(:sponsored_article_2)
#    b.auction = c.auction
#    b.save
#    b.errors.count.should > 0
  end

  it "shouldn`t allow page url change" do
    b = sponsored_articles(:sponsored_article_1)
    b.url = b.url + "supcio"
    b.save
    b.errors.count.should > 0
  end

  it "should be searchable by minimal price" do
    search_scopes= {:auction_minimal_price_gt => 0, :auction_minimal_price_lte => 30}
    sponsored_articles = (SponsoredArticle.prepare_search_scopes(search_scopes)).all
    sponsored_articles.each do |b|
      b.auction.minimal_price.should > 0
      b.auction.minimal_price.should <= 30
    end
    all_sponsored_articles = SponsoredArticle.all
    all_sponsored_articles.each do |b|
      if b.auction.minimal_price > 0 and b.auction.minimal_price <= 30 then
        sponsored_articles.should include(b)
      end
    end
  end

  it "should be searchable by pagerank" do
    search_scopes= {:pagerank_gt => 1, :pagerank_lt => 4}
    sponsored_articles = (SponsoredArticle.prepare_search_scopes(search_scopes)).all
    all_sponsored_articles = SponsoredArticle.all
    sponsored_articles.each do |b|
      b.pagerank.should > 0
      b.pagerank.should < 4
    end

    all_sponsored_articles.each do |b|
      if b.pagerank > 0 and b.pagerank < 4 then
        sponsored_articles.should include(b)
      end
    end
  end

  it "should be searchable by users daily" do
    search_scopes= {:users_daily_gt => 20 , :users_daily_lt => 100}
    sponsored_articles = (SponsoredArticle.prepare_search_scopes(search_scopes)).all
    sponsored_articles.each do |b|
      b.users_daily.should > 20
      b.users_daily.should < 100
    end
    all_sponsored_articles = SponsoredArticle.all
    all_sponsored_articles.each do |b|
      if b.users_daily > 20 and b.users_daily < 100 then
        sponsored_articles.should include(b)
      end
    end
  end

end