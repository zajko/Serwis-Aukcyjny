require File.dirname(__FILE__) + '/../spec_helper'
require "authlogic/test_case"

describe UsersController, "new user with valid values" do
  before(:each) do
    User.stub!(:new).and_return(@proper_user = mock_model(User, :deliver_activation_instructions! => true,:save => true, :has_role! => true, :activation_token => "aktywacja1", :activation_token= => true))
  end
  def do_create
    post :create, :user => {:login => "nowy"}
  end

  it "should create the user" do
   User.should_receive(:new).with("login" => "nowy").and_return(@proper_user)
   @proper_user.should_receive(:save).and_return(true)
   @proper_user.should_receive(:has_role!).and_return(true)
   @proper_user.should_receive(:activation_token=)
   @proper_user.should_receive(:activation_token)
   do_create
  end

  it "should save the user" do
    @proper_user.should_receive(:save).and_return(true)
    @proper_user.should_receive(:has_role!).and_return(true)
    @proper_user.should_receive(:activation_token=)
    @proper_user.should_receive(:activation_token)
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
    User.stub!(:new).and_return(@inproper_user = mock_model(User, :save => false,:deliver_activation_instructions! => true, :has_role! => true, :activation_token= => true))
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

describe UsersController, "administrator" do
  fixtures :users, :roles
  before(:each) do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:user_1)
    UserSession.create(@current)
  end

  def do_ban(id)
    post :ban, :passed_id => id
  end

  def do_destroy
    u = users(:user_2)
    post :destroy, :id => u.id
  end
  
  it "should be able to ban existing user" do
    @user = users(:user_2)
    User.should_receive(:find).at_least(1).times.and_return(@user)
    do_ban(@user.id)
  end

  it "should be able to delete existing user" do
    @user = users(:user_2)
    User.should_receive(:find).at_least(1).times.and_return(@user)
    do_destroy
    
  end
end

describe UsersController, "Existing user" do
  fixtures :users, :roles
  before(:each) do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:user_1)
    UserSession.create(@current)
  end

  def do_update
    post :update, :user => {:login => "kaczor donald"}
  end

  it "should be able to edit attributes" do
    do_update
  end

end

describe UsersController, "existing user" do
  fixtures :users, :roles
  before(:each) do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:user_1)
    UserSession.create(@current)
  end

  def do_show
    @current = users(:user_1)
    post :show, {:id => @current.id}
  end

  it "should be found" do
    #:first, {:conditions => {:id=>@current.id}}
    User.should_receive(:find).at_least(1).times.and_return(@current)
    do_show
  end


  it "should be rendered" do
    #TODO jak to sprawdzic ?
  end

end


describe UsersController, "not existing user" do
  fixtures :users, :roles
  before(:each) do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:user_1)
    UserSession.create(@current)
  end

  def do_show
    post :show, :id => -1500
  end

  it "should not be found" do
    User.should_receive(:find).at_least(1).times.and_raise(ActiveRecord::RecordNotFound)
    begin
      do_show
    rescue ActiveRecord::RecordNotFound 
      
    end
  end

  it "should cause redirect" do
    do_show
    response.should be_redirect
  end

end