require 'spec_helper'

describe SponsoredArticle do
  fixtures :auctions, :sponsored_articles, :users, :bids

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
    search_scopes= {:auction_minimal_price_gt => 0, :auction_minimal_price_lte => 12}
    sponsored_articles = (SponsoredArticle.prepare_search_scopes(search_scopes)).all
    sponsored_articles.each do |b|
      b.auction.minimal_price.should > 0
      b.auction.minimal_price.should < 12
    end
  end

  it "should be searchable by pagerank" do
    search_scopes= {:pagerank_gt => 1, :pagerank_lt => 9}
    sponsored_articles = (SponsoredArticle.prepare_search_scopes(search_scopes)).all
    sponsored_articles.each do |b|
      b.pagerank.should > 0
      b.pagerank.should < 9
    end
  end

  it "should be searchable by users daily" do
    search_scopes= {:users_daily_gt => 5, :pagerank_lt => 20}
    sponsored_articles = (SponsoredArticle.prepare_search_scopes(search_scopes)).all
    sponsored_articles.each do |b|
      b.users_daily > 5
      b.users_daily < 20
    end
  end

end