require File.dirname(__FILE__) + '/../spec_helper'
require "authlogic/test_case"


describe CategoriesController, "user not login" do

  it "should not go to index" do
    lambda { get :index }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to new" do
    lambda { get :new }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to create" do
    lambda { post :create }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to delete" do
    Category.stub!(:find).and_return(@category = mock_model(Category))
    lambda { post :delete, :id=>1 }.should raise_error(Acl9::AccessDenied)
  end
end

describe CategoriesController, "regular user login" do
  fixtures :users, :roles

  before(:each) do
    activate_authlogic
    @current = users(:user_3)
    UserSession.create(@current)
  end

  it "should not go to index" do
    lambda { get :index }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to new" do
    lambda { get :new }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to create" do
    lambda { post :create }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to delete" do
    Category.stub!(:find).and_return(@category = mock_model(Category))
    lambda { post :delete, :id=>1 }.should raise_error(Acl9::AccessDenied)
  end
end

describe CategoriesController, "admin login" do
  fixtures :users, :roles, :categories

  before(:each) do
    activate_authlogic
    @current = users(:user_1)
    UserSession.create(@current)
  end

  it "should go to index" do
    get :index
    response.should be_success
  end

  it "should go to new" do
    get :new
    response.should be_success
  end

  it "should go to create, category create proper" do
    Category.stub!(:new).and_return(@proper_category = mock_model(Category, :save=>true, :name=>"sport-nowy"))
    Category.should_receive(:new).and_return(@proper_category)
      @proper_category.should_receive(:save).and_return(true)
      post :create, :category=>{:name=>"sport-nowy"}
      flash[:notice].should == "Kategoria sport-nowy została utworzona!"
      assigns(:category).should==@proper_category
      response.should redirect_to('categories')
  end

  it "should go to create, category create fail" do
    Category.stub!(:new).and_return(@proper_category = mock_model(Category, :save=>false, :name=>"sport-nowy"))
    Category.should_receive(:new).with("name" => "sport-nowy").and_return(@proper_category)
    @proper_category.should_receive(:save).and_return(false)
    post :create, :category=>{:name=>"sport-nowy"}
    flash[:notice].should == "Błąd przy tworzeniu kategorii sport-nowy."
    assigns(:category).should==@proper_category
    response.should be_success
  end

  it "should go to delete and delete success" do
    Category.stub!(:find).and_return(@category = mock_model(Category, :destroy=>true))
    Category.should_receive(:find).and_return(@category)
    post :delete, :id => @category.id
    flash[:notice].should == "Kategoria została usunięta"
    response.should redirect_to('index')
  end

#  it "should go to delete and delete success" do
#    @category = categories(:sport)
#    post :delete, :id=>@category.id
#    flash[:notice].should == "Kategoria została usunięta"
#    response.should redirect_to('index')
#  end

  it "should go to delete and delete fail" do
    Category.stub!(:find).and_return(@category = mock_model(Category, :destroy=>false))
    Category.should_receive(:find).and_return(@category)
    post :delete, :id=>@category.id
    flash[:notice].should == "Kategoria NIE została usunięta"
    response.should redirect_to('new')
  end
end