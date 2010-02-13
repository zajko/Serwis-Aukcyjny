#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class SponsoredArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  should_have_named_scope :active, :include => :auction, :condition => {'auctions.activated' => true }
  should_have_named_scope :activated, { :joins => :auction, :conditions => { "auctions.activated" => true }}
  should_have_named_scope 'order_scope("desc")', { :order => 'desc'}
  should_have_named_scope 'order_auction_scope("auction_end DESC")', :joins => :auction, :conditions => "sponsored_articles.id=sponsored_articles.id", :order => "auction_end DESC"
  should_have_named_scope 'by_auctions_id(12,14)', :include => :auction,
      :conditions => ["auction.id IN (?)", [12,14]]
  should_have_named_scope 'by_categories_id(1,2)', :select => "sponsored_articles.*",
      :joins => "INNER JOIN auctions as A ON auctionable_type = 'SponsoredArticle' AND auctionable_id = sponsored_articles.id INNER JOIN auctions_categories AS AC ON A.id = AC.auction_id INNER JOIN categories ON categories.id = AC.category_id",
      :conditions => ["categories.id IN (?)", [1,2]]

  def test_create_new_sponsored_article
#    nowy banner
  assert_difference 'SponsoredArticle.count' do
    sponsoredArticle = SponsoredArticle.new
    sponsoredArticle.url = 'http://www.o2.pl'
    sponsoredArticle.pagerank = 2
    sponsoredArticle.users_daily =100
    sponsoredArticle.words_number = 100
    sponsoredArticle.number_of_links = 10
    assert sponsoredArticle.valid?
    assert sponsoredArticle.save, sponsoredArticle.errors.full_messages
    #    dodaje aucje do akrtykulu sponsorowanego
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.auctionable_id = sponsoredArticle.id
    auction.auctionable_type = "SponsoredArticle"
    assert auction.save, auction.errors.full_messages
  end
#    uppdate banner
  assert_no_difference 'SponsoredArticle.count' do
    sponsoredArticle = SponsoredArticle.last
    assert_not_nil sponsoredArticle

    sponsoredArticle.update_attributes(:pagerank=>10)
    assert_match(/Nie można zmienić pageranku/, sponsoredArticle.errors.on(:s))
    sponsoredArticle.save

    sponsoredArticle = SponsoredArticle.last
    sponsoredArticle.update_attributes(:url=>'http://www.google.pl')
    assert_match(/Nie można zmienić adresu strony/, sponsoredArticle.errors.on(:s))
    sponsoredArticle.save

    sponsoredArticle = SponsoredArticle.last
    sponsoredArticle.update_attributes(:users_daily=>1)
    assert_match(/Nie można zmienić liczby dziennych użytkowników/, sponsoredArticle.errors.on(:s))
    sponsoredArticle.save

    sponsoredArticle = SponsoredArticle.last
    sponsoredArticle.update_attributes(:words_number=>1)
    assert_nil sponsoredArticle.errors.on(:s)
    sponsoredArticle.save

    sponsoredArticle = SponsoredArticle.last
    sponsoredArticle.update_attributes(:number_of_links=>1)
    assert_nil sponsoredArticle.errors.on(:s)
    sponsoredArticle.save

#    dodaje bid
    bid = Bid.new
    auction = sponsoredArticle.auction
    bid.auction_id=auction.id
    bid.offered_price=1000
    bid.user_id = users(:jarek1)
    auction.activated=true
    auction.save
    assert bid.save, bid.errors.full_messages

      
    sponsoredArticle = SponsoredArticle.last
    sponsoredArticle.words_number=10
    assert !sponsoredArticle.save
    assert_match(/Nie można zmienić liczby słów artykułu gdy są nieanulowane oferty/, sponsoredArticle.errors.on(:s))

    sponsoredArticle = SponsoredArticle.last
    sponsoredArticle.number_of_links=10
    sponsoredArticle.save
    assert_match(/Nie można zmienić liczby linków w artykule gdy są nieanulowane oferty/, sponsoredArticle.errors.on(:s))

  end
end

  def test_prepare_search_scopes
    sponsoredArticleSearch = SponsoredArticle.searchObject(:pagerank_gte => 1,
                                                         :pagerank_lte => 10,
                                                         :users_daily_gte => 100,
                                                         :users_daily_lte => 500,
                                                         :number_of_links_gte => 1,
                                                         :number_of_links_lte => 100,
                                                         :words_number_gte => 1,
                                                         :words_number_lte => 1000,
                                                      #   :minimum_days_until_end_of_auction => 1,
                                                      #   :maximum_days_until_end_of_auction => 10,
                                                         :product_type => "SponsoredArticle")
   @cats
   assert_not_nil sponsoredArticleSearch
   @atrb = "sport","muzyka"
   sponsoredArticleSearch.categories_attributes=(@atrb)
   @pom = []
   @pom = @pom.push(@atrb)
   @cat = sponsoredArticleSearch.categories
   assert_equal @pom, @cat
   sponsoredArticleSearch.categories=("cat")
   sponsoredArticleSearch = sponsoredArticleSearch.attributes
   assert_not_nil sponsoredArticleSearch
   assert SponsoredArticle.prepare_search_scopes(sponsoredArticleSearch).count>0
 end

 def test_prepare_search_scopes2
   #    gdy nie mam aukcji aktywnych
   scope = SponsoredArticle.search(:all)
    scope = scope.activated
    sponsoredArticleSearch = nil
  #  assert_equal scope, SponsoredArticle.preaare_search_scopes(sponsoredArticleSearch)
    sponsoredArticleSearch = ProductSearch.new
    #(:pagerank_gte => 1,
#                                                         :pagerank_lte => 10,
#                                                         :users_daily_gte => 1,
#                                                         :users_daily_lte => 500,
#                                                         :number_of_links_gte => 1,
#                                                         :number_of_links_lte => 100,
#                                                         :words_number_gte => 1,
#                                                         :words_number_lte => 1000,
#                                                      #   :minimum_days_until_end_of_auction => 1,
#                                                      #   :maximum_days_until_end_of_auction => 10,
#                                                         :product_type => "SponsoredArticle")
sponsoredArticleSearch.pagerank_gte=1
sponsoredArticleSearch = sponsoredArticleSearch.attributes
    assert_not_nil sponsoredArticleSearch

    sponsoredArticle = SponsoredArticle.new
    sponsoredArticle.url = 'http://www.o2.pl'
    sponsoredArticle.pagerank = 2
    sponsoredArticle.users_daily =100
    sponsoredArticle.words_number = 100
    sponsoredArticle.number_of_links = 10
    assert sponsoredArticle.valid?
    assert sponsoredArticle.save, sponsoredArticle.errors.full_messages
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    #auction.auctionable_id = sponsoredArticle.id
    #auction.auctionable_type = "SponsoredArticle"
    auction.auctionable = sponsoredArticle

    assert auction.save, auction.errors.full_messages
   
    assert_not_nil SponsoredArticle.prepare_search_scopes(sponsoredArticleSearch)
#    aukcja aktywna (druga)
    assert Auction.by_type("SponsoredArticle").count>0
    sponsoredArticle = sponsored_articles(:google)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.auctionable_id = sponsoredArticle.id
    auction.auctionable_type = "SponsoredArticle"
    assert auction.save, auction.errors.full_messages
    assert Auction.by_type("SponsoredArticle").count>0
    assert_not_nil sponsoredArticleSearch
    assert  SponsoredArticle.prepare_search_scopes(sponsoredArticleSearch).count>0
 end
 
  test "the truth" do
    assert true
  end
end
