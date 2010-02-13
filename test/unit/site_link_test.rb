#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class SiteLinkTest < ActiveSupport::TestCase
  # Replace this with your real tests.
   should_have_named_scope :active, :include => :auction, :condition => {'auctions.activated' => true }
   should_have_named_scope :activated, { :joins => :auction, :conditions => { "auctions.activated" => true }}
   should_have_named_scope 'order_scope("desc")', :order => "desc"
   should_have_named_scope 'order_by_auction("id")', :join => :auction, :order=> "auction."+"id"
#   ??????
   should_have_named_scope 'pagerank_gte(2)', :conditions => ["site_links.pagerank >= (?)", 2]
   should_have_named_scope 'order_auction_scope("desc")', :conditions => "site_links.id =site_links.id", :joins => :auction, :order => "desc"
   should_have_named_scope 'by_auctions_id(10,15)', :include => :auction, :conditions => ["auction.id IN (?)", [10,15]]
   should_have_named_scope 'by_categories_id(1,2)', :select => "site_links.*",
      :joins => "INNER JOIN auctions AS A ON auctionable_type = 'SiteLink' AND auctionable_id = site_links.id INNER JOIN auctions_categories AS AC ON A.id = AC.auction_id INNER JOIN categories ON categories.id = AC.category_id",
      :conditions => ["categories.id IN (?)", [1,2]]
   should_have_named_scope 'pagerank_lte(10)', :conditions => ["site_links.pagerank <= (?)", 10]
   should_have_named_scope 'users_daily_gte(100)', :conditions => ["site_links.users_daily >= (?)", 100]
   should_have_named_scope 'users_daily_lte(1000)', :conditions => ["site_links.users_daily <= (?)", 1000]
   should_have_named_scope 'by_categories_name("sport","muzyka")', :include => :categories,
      :conditions => ["categories.name IN (?)", ["sport","muzyka"]]
   should_have_named_scope 'by_catss()', :include => :auction,
      :conditions => ["auctions.auctionable_type = (?)", self.class.to_s]

def test_create_new_site_link
#    nowy banner
  assert_difference 'SiteLink.count' do
    siteLink = SiteLink.new
    siteLink.url = 'http://www.o2.pl'
    siteLink.pagerank = 2
    siteLink.users_daily =100
    assert siteLink.valid?
    assert siteLink.save, siteLink.errors.full_messages
    #    dodaje aucje do banner
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.auctionable_id = siteLink.id
    auction.auctionable_type = "SiteLink"
    assert auction.save, auction.errors.full_messages
    assert Auction.by_type("SiteLink").count>1
  end
#    uppdate banner
  assert_no_difference 'SiteLink.count' do
    siteLink = SiteLink.last
    assert_not_nil siteLink

    siteLink.update_attributes(:pagerank=>10)
    assert_match(/Nie można zmienić pageranku/, siteLink.errors.on(:s))
    siteLink.save

    siteLink = SiteLink.last
    siteLink.update_attributes(:url=>'http://www.google.pl')
    assert_match(/Nie można zmienić adresu strony/, siteLink.errors.on(:s))
    siteLink.save

    siteLink = SiteLink.last
    siteLink.update_attributes(:users_daily=>1)
    assert_match(/Nie można zmienić liczby dziennych użytkowników/, siteLink.errors.on(:s))
    siteLink.save

    auction2 = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction2.user_id = user.id
    auction2.start = Date.today()+1.days
    auction2.auction_end=Date.today()+2.days
    auction2.activated = true
    auction2.auctionable_id = siteLink.id
    auction2.auctionable_type = "SiteLink"
    assert auction2.save, auction2.errors.full_messages
    siteLink = SiteLink.last
    siteLink.update_attributes(:auction=>auction2)
#    assert_match(/Nie można zmienić aukcji produktu/, siteLink.errors.on(:s))
    siteLink.save
  end
end

  def test_prepare_search_scopes
   siteLinkSearch = SiteLinkSearch.new
   siteLinkSearch.pagerank_gte = 1
   siteLinkSearch.pagerank_lte = 10
   siteLinkSearch.users_daily_gte = 100
   siteLinkSearch.users_daily_lte = 1000
#   siteLinkSearch.minimum_days_until_end_of_auction = 1
#   siteLinkSearch.maximum_days_until_end_of_auction = 10
   siteLinkSearch.product_type = "SiteLink"
   @cats
   assert_not_nil siteLinkSearch
   @atrb = "sport","muzyka"
   siteLinkSearch.categories_attributes=(@atrb)
   @pom = []
   @pom = @pom.push(@atrb)
   @cat = siteLinkSearch.categories
   assert_equal @pom, @cat
   siteLinkSearch.categories=("cat")
   assert_equal 0, SiteLink.prepare_search_scopes(siteLinkSearch).count
 end

 def test_prepare_search_scopes2
   assert_no_difference 'SiteLink.count' do
   #    gdy nie mam aukcji aktywnych
    scope = SiteLink.scoped({})
    scope = scope.activated
    siteLinkSearch = nil
    assert_equal scope, SiteLink.prepare_search_scopes(siteLinkSearch)
    siteLinkSearch = SiteLinkSearch.new
    siteLinkSearch.pagerank_gte = 1
    siteLinkSearch.pagerank_lte = 10
    siteLinkSearch.users_daily_gte = 100
    siteLinkSearch.users_daily_lte = 1000
#    siteLinkSearch.minimum_days_until_end_of_auction = 1
#    siteLinkSearch.maximum_days_until_end_of_auction = 10
    siteLinkSearch.product_type = "SiteLink"
    assert_equal 0, SiteLink.prepare_search_scopes(siteLinkSearch).count
#    aukcja aktywna (druga)
    assert_equal 0, SiteLink.by_catss().count
    siteLink = site_links(:google)
    auction = Auction.new
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.auctionable_id = siteLink.id
    auction.auctionable_type = "SiteLink"
    assert auction.save, auction.errors.full_messages
    assert_equal 1, SiteLink.prepare_search_scopes(siteLinkSearch).count
   end
 end


# class SiteLinkSearch < Tableless
# # has_many :categories
#  #accepts_nested_attributes_for :categories
#  column :pagerank_gte, :integer
#  column :pagerank_lte, :integer
#  column :pagerank_lte, :integer
#  column :pagerank_gte, :integer
#  column :users_daily_gte, :integer
#  column :users_daily_lte, :integer
#  column :minimum_days_until_end_of_auction, :integer
#  column :maximum_days_until_end_of_auction, :integer
#  column :product_type, :string
#  @cats
#  def categories_attributes=(atr)
#    @cats = []
#    @cats.push(atr)
#  end
#  #@categories = Category.all#.map{|t| t.name}
#  def categories=(cat)
#  #  @categories = {}
#  # @categories.merge(cat)
#  end
#  def categories
#    @cats
#  end
#
#
#
#  test "the truth" do
#    assert true
#  end
end
