require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, "new user with valid values" do
  before(:each) do
    User.stub!(:new).and_return(@proper_user = mock_model(User, :save => true, :has_role! => true, :activation_token= => true))
  end
  def do_create
    post :create, :user => {:login => "nowy"}
  end

  it "should create the user" do
   User.should_receive(:new).with("login" => "nowy").and_return(@proper_user)
   do_create
  end

  it "should save the user" do
    @proper_user.should_receive(:save).and_return(true)
    @proper_user.should_receive(:has_role!).and_return(true)
    @proper_user.should_receive(:activation_token=)
    do_create
  end

  it "should assign user" do
    do_create
    assigns(:user).should==@proper_user
  end

  it "should be redirect" do
    do_create
    response.should be_redirect
  end

  it "should be redirect to account" do
    do_create
    response.should redirect_to(account_url)
  end
end



describe UsersController, "new user with invalid values" do
  before(:each) do
    User.stub!(:new).and_return(@inproper_user = mock_model(User, :save => false, :has_role! => true, :activation_token= => true))
  end
  def do_create
    post :create, :user => {:login => "nowy"}
  end

  it "should create the user" do
   User.should_receive(:new).with("login" => "nowy").and_return(@inproper_user)
   do_create
  end

  it "should save the user" do
    @inproper_user.should_receive(:save).and_return(false)
    @inproper_user.should_not_receive(:has_role!)
    @inproper_user.should_receive(:activation_token=)
    do_create
  end

  it "should assign user" do
    do_create
    assigns(:user).should==@inproper_user
  end

  it "should be redirect" do
    do_create
    response.should be_success
  end

  it "should be redirect to account" do
    do_create
    response.should render_template("new")
  end
end

#
#describe UsersController, "existing user" do
#  before(:each) do
#    login({}, {:roles => {'admin' => nil} })
#    User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
#  end
#
#  def do_show
#    post :show, {:id => 1500}
#  end
#
#  it "should be found" do
#    User.should_receive(:find).with(1500).and_return(@user)
#    do_show
#  end
#
#  it "should be assigned to variable" do
#    do_show
#    assigns(:user) == @user
#  end
#
#  it "should be rendered" do
#    #TODO jak to sprawdzic ?
#  end
#
#end
#
#
#describe UsersController, "not existing user" do
#  before(:each) do
#    login({}, {:roles => {'admin' => nil} })
#    User.stub!(:find).and_raise(ActiveRecord::RecordNotFound)
#  end
#
#  def do_show
#    post :show, :id => 1500
#  end
#
#  it "should not be found" do
#    User.should_receive(:find).with(:id => 1500).and_raise(ActiveRecord::RecordNotFound)
#    UserSession.should_receive(:record)
#    do_show
#  end
#
#  it "should cause redirect" do
#    do_show
#    response.should be_redirect
#  end
#
#  it "should cause redirect to root" do
#    do_show
#    response.should redirect_to("/")
#  end
#end