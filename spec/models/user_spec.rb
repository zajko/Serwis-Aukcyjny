# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  fixtures :auctions, :site_links, :banners, :users, :pop_ups, :sponsored_articles, :bids, :roles

  it { should allow_value("example@mail.com").for(:email) }
  it { should_not allow_value("mielonka mielonka mielonka").for(:email) }

  
  def create_user(params)
    user = User.new
    user.email = params[:email]
    user.login = params[:login]
    user.password = params[:password]
    user.password_confirmation = params[:password_confirmation]
    user.save
    user
  end
context "#czy_ma_role" do
  it "user admin should have role admin" do
    u = users(:user_1)
    u.has_role?(:admin).should == true
  end
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
    it "there can be maximally one superuser" do
      @user1 = users(:user_superuser)
      if @user1.has_role?(:superuser) == false
        raise "Źle przygotowane dane testowe - ten użytkownik powinien być superuserem"
      end
      @user2 = users(:user_2)
      @user2.has_role!("superuser").should==false
    end
    it "cannot delete role superuser from superuser" do
      @user = users(:user_superuser)
      if @user.has_role?(:superuser) == false
        raise "Źle przygotowane dane testowe - ten użytkownik powinien być superuserem"
      end
      @user.has_no_role!(:superuser)
      @user.has_role?(:superuser).should==true
    end

    it "cannot ban superuser" do
      @user = users(:user_superuser)
      if @user.has_role?(:superuser) == false
        raise "Źle przygotowane dane testowe - ten użytkownik powinien być superuserem"
      end
      @user.has_no_role!(:superuser)
      @user.ban
#      przy ban powinien też byc error, ze superusera nie mozna zbanowac
      @user.errors.count.should > 0
    end


    it "cannot not-activated superuser" do
      @user = users(:user_superuser)
      if @user.has_role?(:superuser) == false
        raise "Źle przygotowane dane testowe - ten użytkownik powinien być superuserem"
      end
      @user.has_role!(:not_activated)
      @user.has_role?(:not_activated).should==false
    end


    #A skad ty to wziales ?
#    it "user with no roles becomes superuser" do
#      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
#      @user.has_no_role!(:not_activated)
#      @user.should have(0).roles
#      @user.superuser!
#      @user.has_role?(:superuser).should be_true
#    end

 #Skad ty to wziales ?
#    it "cannot remove role admin from superuser" do
#      @user = create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
#      @user.admin!
#      @user.has_role?(:admin).should be_true
#      @user.superuser!
#      @user.has_role?(:superuser).should be_true
#      @user.no_admin!
#      @user.has_role?(:admin).should be_false
#    end

    it "ban new user" do
      @user = users(:aga)#create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      if(@user.has_role?(:superuser) or @user.has_role?(:admin))
        raise "Źle przygotowane dane testowe - ten użytkownik nie powinien być ani administratorem ani superużytkownikiem"
      end
      @user.ban
      @user.banned?.should be_true
    end
    
    it "unban user with role banned" do
      @user = users(:aga)#create_user(:login=>'jarek',:email=>'jarek@onet.pl', :password=>'1234', :password_confirmation=>'1234')
      if(@user.has_role?(:superuser) or @user.has_role?(:admin))
        raise "Źle przygotowane dane testowe - ten użytkownik nie powinien być ani administratorem ani superużytkownikiem"
      end
      @user.ban
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
    it "cannot remove user with open auction" do
      @user = users(:user_1)
     
      @user.destroy.should == false
    end
  end
end

#describe User do
#  it { should belong_to(:account) }
#  it { should have_many(:posts) }
#  it { should validate_presence_of(:email) }
#  it { should allow_value("test@example.com").for(:email) }
#  it { should_not allow_value("test").for(:email) }
#end