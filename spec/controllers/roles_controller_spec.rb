require File.dirname(__FILE__) + '/../spec_helper'
require "authlogic/test_case"

describe RolesController, "new role with valid values add by admin" do
  fixtures :users, :roles
  
  before(:each) do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:user_1)
    UserSession.create(@current)
    Role.stub!(:new).and_return(@proper_role = mock_model(Role, :save=>true))
  end
  def do_create
    post :create, :role => {:name => "nowa"}
  end

  it "should save the role" do
    @proper_role.should_receive(:save).and_return(true)
    do_create
  end

  it "should create the role" do
   Role.should_receive(:new).with("name" => "nowa").and_return(@proper_role)
   do_create
   flash[:notice].should == "Utworzono rolę!"
  end

  it "should assign role" do
    do_create
    assigns(:role).should==@proper_role
  end

  it "should be redirect" do
    do_create
    response.should be_redirect
  end

  it "should be redirect to index" do
    do_create
#    notice.should equal("Utworzono rolę!")
    response.should redirect_to('roles')
  end

end

describe RolesController, "new role with not valid values add by admin" do
  fixtures :users, :roles

  before(:each) do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:user_1)
    UserSession.create(@current)
    Role.stub!(:new).and_return(@fail_role = mock_model(Role, :save=>RuntimeError ))
  end
  def do_create
    post :create, :role => {:name => "nowa"}
  end

  it "should save the role" do
    @fail_role.should_receive(:save).and_return(RuntimeError)
    do_create
  end

  it "should create the role" do
   Role.should_receive(:new).with("name" => "nowa").and_return(RuntimeError)
   do_create
   flash[:notice].should == "Błąd przy tworzeniu roli!"
  end

  it "should assign role" do
    do_create
    assigns(:role).should==@fail_role
  end

  it "should be redirect" do
    do_create
    response.should be_redirect
  end

  it "should be redirect to index" do
    do_create
#    notice.should equal("Utworzono rolę!")
    response.should redirect_to('roles')
  end

end

describe RolesController, "new role with valid values add by regular user" do
  fixtures :users, :roles

  before(:each) do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:user_3)
    UserSession.create(@current)
    Role.stub!(:new).and_return(@proper_role = mock_model(Role, :save=>true))
  end
  def do_create
    post :create, :role => {:name => "nowa"}
  end

  it "should save the role" do
    lambda { do_create }.should raise_error(Acl9::AccessDenied)

  end

end

describe RolesController, "add/remove role to/from user by admin" do
  fixtures :users, :roles

  before(:each) do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:user_1)
    UserSession.create(@current)
  end

  it "should add new role to user" do
    @user = users(:not_activated_user)
    @role = roles(:not_activated)
    post :add_role_to_user, :role_id=>@role.id, :user_id=>@user.id
    response.should be_redirect
    flash[:notice].should == "Użytkownik not_active już ma rolę not_activated"
  end

  it "should add new role to user" do
#    User.stub!(:find).with(1).and_return(@proper_user = mock_model(User,  :login=>"ktos", :roles=> []))
#    Role.stub!(:find).with(1).and_return(@proper_role = mock_model(Role))
    @user = users(:not_activated_user)
    @role = roles(:owner)
    post :add_role_to_user, :role_id=>@role.id, :user_id=>@user.id
   response.should be_redirect
    flash[:notice].should == "Użytkownikowi not_active przyznano rolę owner"
  end

  it "should add new role to user" do
    @user = users(:not_activated_user)
    @role = roles(:not_activated)
    post :remove_role_from_user  , :role_id=>@role.id, :user_id=>@user.id
    response.should be_redirect
    flash[:notice].should == "Użytkownikowi not_active odebrano rolę not_activated"
  end

  it "should remove role from user" do
#    User.stub!(:find).with(1).and_return(@proper_user = mock_model(User,  :login=>"ktos", :roles=> []))
#    Role.stub!(:find).with(1).and_return(@proper_role = mock_model(Role))
    @user = users(:not_activated_user)
    @role = roles(:owner)
    raise "Źle dobrane dane testowe" if @user.roles.include?(@role)
    post :remove_role_from_user  , :role_id=>@role.id, :user_id=>@user.id
    response.should be_redirect
    flash[:notice].should == "Użytkownik not_active nie ma roli owner"
  end
end
