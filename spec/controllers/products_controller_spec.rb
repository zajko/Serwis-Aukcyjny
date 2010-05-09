require 'spec_helper'

describe ProductsController, "existing Auction when showing" do

  def do_show
    post :show, :id => 1, :product_type => "site_link"
  end

  before(:each) do
    Auction.stub!(:find).and_return(@existing_auction= mock_model(Auction))
    @auctionable = mock_model(SiteLink, :class => "SiteLink", :auction => @existing_auction)
    
    Bid.stub!(:new).and_return(@bid_new = mock_model(Bid))
    SiteLink.stub!(:find).and_return(@auctionable)
    Kernel.stub!(:const_get).and_return(SiteLink)
  end

  it "should create new Bid" do
    Bid.should_receive(:new).and_return(@bid_new)
    do_show
  end

  it "should reflect the proper product class" do
    Kernel.should_receive(:const_get).with("SiteLink").and_return(SiteLink)
    do_show
  end

  it "should search for the proper auction" do
    SiteLink.should_receive(:find).at_least(1).times.and_return(@auctionable)
    do_show
  end
  
  it "should assign the product" do
    do_show
    assigns(:product).should== @auctionable
  end

  it "should assign bid" do
    do_show
    assigns(:bid).should== @bid_new
  end
end


describe ProductsController, "existing Auction with activate -> true" do
 # fixtures :users, :roles
  #Delete this example and add some real ones

  def show_activate
    post :activate, :id => 1, :product_type => "site_link"
  end


  
  before(:each) do

    @auctionable = mock_model(SiteLink, :class => "SiteLink")    
    Auction.stub!(:find).and_return(@existing_auction= mock_model(Auction, :auctionable => @auctionable, :activate => true))

  end

  it "should be queried for activate" do
    Auction.should_receive(:find).at_least(1).times.and_return(@existing_auction)
    @existing_auction.should_receive(:activate)
    show_activate
  end

  it "should be redirect to show product" do
    show_activate
    response.should be_redirect
  end

  it "should assign the auction" do
    show_activate
    assigns(:auction).should==@existing_auction
  end
end

describe ProductsController, "existing Auction with activate -> false" do

  def show_activate
    post :activate, :id => 1, :product_type => "site_link"
  end
  
  before(:each) do
    Auction.stub!(:find).and_return(@existing_auction= mock_model(Auction, :auctionable => (mock_model(SiteLink, :class => "SiteLink")), :activate => false))
  end

  it "should be queried for activate" do
    Auction.should_receive(:find).at_least(1).times.and_return(@existing_auction)
    @existing_auction.should_receive(:activate)
    show_activate
  end
  it "should render show" do
    #show_activate
    #response.should render_template("products/show.html.erb")
    #TO JEST ŹLE SFORMUŁOWANY SPEC !
  end
  it "should assign the auction" do
    show_activate
    assigns(:auction).should==@existing_auction
  end
end


describe ProductsController, "not existing Auction" do

  def show_activate
    post :activate, :id => 1, :product_type => "site_link"
  end

  before(:each) do
    Auction.stub!(:find).and_return(@existing_auction= nil)
  end

  it "should be queried for activate" do
    Auction.should_receive(:find).at_least(1).times.and_return(@user)
    show_activate
  end
  it "should redirect to root" do
    show_activate
    response.should redirect_to("/")
  end
  it "should assign the auction" do
    show_activate
    assigns(:auction).should==@existing_auction
  end
end