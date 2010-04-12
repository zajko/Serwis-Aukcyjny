# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../spec_helper'

describe ArchivalUser do
  fixtures :auctions, :site_links, :banners, :users, :pop_ups, :sponsored_articles, :bids
  def create_archival_user(params)
    user = ArchivalUser.new
    user.email = params[:email]
    user.login = params[:login]
    user.crypted_password = params[:crypted_password]
    user.password_salt = params[:password_salt]
    user.first_name = params[:first_name]
    user.surname = params[:surname]
    user.user_creation_time = params[:user_creation_time]
    user.save
    user
  end

  it "should allow save user with all fill in filds" do
    pom = users(:user_3)
    user = ArchivalUser.new
    user.email = pom.email
    user.login = pom.login
    user.crypted_password = pom.crypted_password
    user.password_salt = pom.password_salt
    user.first_name = pom.first_name
    user.surname = pom.surname
    user.user_creation_time = pom.created_at
    
    user.save.should be_true
  end

  context "#powiazania" do
   it { should have_many(:archival_bids) }
#   it { should have_many(:charges) }
   it { should have_many(:payments) }
   it { should have_many(:archival_auctions) }
  end

  it "should copy attributes beetween user and archival user without save" do
    user = users(:user_3)
    archival_user = ArchivalUser.new
    archival_user = ArchivalUser.copy_attributes_between_models(user, archival_user)
    archival_user.new_record?.should be_true
  end
  it "should copy attributes beetween user and archival user with save option" do
    user = users(:user_3)
    archival_user = ArchivalUser.new
    pending ("nie mozna dac opcji save, bo wywola to blad user_creation_time jest nil") do archival_user = ArchivalUser.copy_attributes_between_models(user, archival_user, {:save=>'true'})
    archival_user.new_record?.should be_false
    end
  end
  it "should save new archival user " do
    user = users(:user_3)
    archival_user = ArchivalUser.new
    archival_user = ArchivalUser.copy_attributes_between_models(user, archival_user)
    archival_user.user_creation_time = user.created_at
    archival_user.save.should be_true
  end
  it "should save new archival user with auction" do
    user = users(:user_3)
    siteLink = SiteLink.new
    siteLink.url = 'http://www.o2.pl'
    siteLink.pagerank = 5
    siteLink.users_daily = 500
    siteLink.save.should be_true
    auction = Auction.new
    auction.user = user
    auction.start = Time.now()
    auction.auction_end = Time.now()+10.days
    auction.buy_now_price = 30
    auction.time_of_service = 50
    auction.activated = false
    auction.created_at = Time.now()
    auction.auctionable_id = siteLink.id
    auction.auctionable_type = 'SiteLink'
    auction.save.should be_true


    archival_user = ArchivalUser.from_user(user)
    archival_user.user_creation_time = user.created_at
    archival_user.save.should be_true

  end
#  context "#email" do
#  before(:each) do
#    @pom = users(:user_3)
#    @user = create_archival_user(:login=>@pom.login,:email=>'unikatoasdfadsgfdagjjyggahtwy@onet.pl', :crypted_password=>@pom.crypted_password, :password_salt=>@pom.password_salt, :first_name=>@pom.first_name, :surname=>@pom.surname, :user_creation_time=>@pom.created_at)
#  end
#
#   it { should validate_presence_of(:email) }
#   it { should allow_value("test@example.com").for(:email) }
#   it { should_not allow_value("test").for(:email) }
#it "jak sprawdzic ze email nie powtarza sie w user i archivaluser podobnie dla loginu"
#   it { should validate_uniqueness_of(:email) }
#
#  end
#
#  context "#login" do
#    before(:each) do
#     @pom = users(:user_3)
#     @user = create_archival_user(:login=>@pom.login,:email=>@pom.email, :crypted_password=>@pom.crypted_password, :password_salt=>@pom.password_salt, :first_name=>@pom.first_name, :surname=>@pom.surname, :user_creation_time=>@pom.created_at)
#    end
#
#    it { should validate_presence_of(:login) }
#    it { should validate_uniqueness_of(:login) }
#  #  pending do it { should ensure_length_of(:login).is_at_least(3)} end
#  end

  
end

