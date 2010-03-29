# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  fixtures :auctions, :site_links, :banners, :users, :pop_ups, :sponsored_articles, :bids
  def create_user(params)
    user = User.new
    user.email = params[:email]
    user.login = params[:login]
    user.password = params[:password]
    user.password_confirmation = params[:password_confirmation]
    user.save
    user
  end

context "#scope" do
  it {should have_named_scope('by_interests_id(1,2)').finding(:include => :interests,
      :conditions => ["interests.id IN (?)", [1,2]])}
  it {should have_named_scope('by_roles_id(1,2,3)').finding(:include => :roles,
      :conditions => ["roles.id IN (?)", [1,2,3]]) }
end

context "#powiazania" do
   it { should have_many(:bids) }
   it { should have_many(:articles) }
   it { should have_many(:charges) }
   it { should have_many(:payments) }
   it { should have_many(:auctions) }
   it { should have_and_belong_to_many(:roles) }
   it { should have_and_belong_to_many(:observed) }
   it { should have_and_belong_to_many(:interests) }

end

context "#email" do
  before(:each) do
    @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
  end

   it { should validate_presence_of(:email) }
   it { should allow_value("test@example.com").for(:email) }
   it { should_not allow_value("test").for(:email) }
   it { should validate_uniqueness_of(:email) }

end

context "#login" do
  before(:each) do
    @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
  end

  it { should validate_presence_of(:login) }
  it { should validate_uniqueness_of(:login) }
#  pending do it { should ensure_length_of(:login).is_at_least(3)} end
end

context "#user roles" do
    it "new user is not admin"do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.is_admin?.should be_false
    end
    it "new user is not activeted" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.has_role?(:not_activated).should be_true
    end
    it "user have no roles after remove not_activated role" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.has_no_role!(:not_activated)
      @user.should have(0).roles
    end
    it "new user add role superuser" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.superuser!
      pending ("do poprawki") do
        @user.has_role?(:not_activated).should be_false
      end
      @user.has_role?(:superuser).should be_true
    end
    it "cannot delete role superuser from superuser" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.has_no_role!(:not_activated)
      @user.superuser!
      @user.has_no_role!(:superuser)
      @user.errors.count.should > 0
    end
    it "cannot ban superuser" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.has_no_role!(:not_activated)
      @user.superuser!
      pending ("do poprawki") do
      @user.ban
#      przy ban powinien też byc error, ze superusera nie mozna zbanowac
      @user.errors.count.should > 0
      end
    end
    it "cannot not-activated superuser" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.has_no_role!(:not_activated)
      @user.superuser!
      @user.has_role!(:not_activated)
      @user.errors.count.should > 0
    end
    it "user with no roles becomes superuser" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.has_no_role!(:not_activated)
      @user.should have(0).roles
      @user.superuser!
      @user.has_role?(:superuser).should be_true
    end
    it "cannot remove role admin from superuser" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.admin!
      @user.has_role?(:admin).should be_true
      @user.superuser!
      @user.has_role?(:superuser).should be_true
      @user.no_admin!
      @user.has_role?(:admin).should be_false
    end
    it "ban new user" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.ban
      @user.banned?.should be_true
    end
    it "unban user with role banned" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.ban
      @user.banned?.should be_true
      @user.unban
      @user.banned?.should be_false
    end
end

  context "inne metody" do
    it "new user activate correct with single_access_token" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      lambda { @user.activate! @user.single_access_token}.should_not raise_error(RuntimeError,
        "Podany token jest niezgodny z tokenem użytkownika")
    end
    it "new user activate incorrect with bad single_access_token" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      lambda { @user.activate! 'badtoken'}.should raise_error(RuntimeError,
        "Podany token jest niezgodny z tokenem użytkownika")
    end
    it "user sucessed remove" do
      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      @user.destroy
      @user.errors.count.should == 0 
    end
    it "cannot remove user with not canceled bids" do
      @user = users(:user_3)
      @user.destroy
      @user.errors.count.should > 0
    end
    it "cannot remove user with open auction" 
  end
end

#describe User do
#  it { should belong_to(:account) }
#  it { should have_many(:posts) }
#  it { should validate_presence_of(:email) }
#  it { should allow_value("test@example.com").for(:email) }
#  it { should_not allow_value("test").for(:email) }
#end