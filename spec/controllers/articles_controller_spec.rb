require File.dirname(__FILE__) + '/../spec_helper'
require "authlogic/test_case"


describe ArticlesController, "user not login" do

  it "should go to index" do
    get :index
    response.should be_success
  end

  it "should go to show" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    post :show, :id=>1
    flash[:notice].should == "Artykul szczegoly"
    response.should be_success
  end

  it "should not go to new" do
    lambda { get :new }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to create" do
    lambda { post :create }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to edit" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    lambda { post :edit, :id=>1 }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to update" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    lambda { post :update, :id=>1 }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to destroy" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    lambda { post :destroy, :id=>1 }.should raise_error(Acl9::AccessDenied)
  end
end

describe ArticlesController, "admin login" do
  fixtures :users, :roles
  
  before(:each) do
    activate_authlogic
    @current = users(:user_1)
    UserSession.create(@current)
  end

  it "should go to index" do
    get :index
    response.should be_success
  end

  it "should go to show" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    post :show, :id=>1
    flash[:notice].should == "Artykul szczegoly"
    response.should be_success
  end

  it "should go to new" do
    get :new
#    assigns(:article).should have(3).attachments
    response.should be_success
  end

  it "should go to create" do
    Article.stub!(:new).and_return(@article = mock_model(Article, :save=>true, :user= => true))
    post :create, :article => {:title => "nowy", :text=>'tekst'}
    assigns(:article).should_not be_nil
    flash[:notice].should == "Artykuł został dodany"
    response.should redirect_to('articles')
  end

  it "should go to create" do
    Article.stub!(:new).and_return(@article = mock_model(Article, :save=>false, :user= => true))
    post :create, :article => {:title => "nowy", :text=>'tekst'}
    assigns(:article).should_not be_nil
    flash[:notice].should == "Błąd: Nie udało się dodać artykułu"
    response.should be_success
  end

  it "should not go to edit" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    lambda { post :edit, :id=>1 }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to update" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    lambda { post :update, :id=>1 }.should raise_error(Acl9::AccessDenied)
  end

  it "should not go to destroy" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    lambda { post :destroy, :id=>1 }.should raise_error(Acl9::AccessDenied)
  end
end

describe ArticlesController, "superuser login" do
  fixtures :users, :roles

  before(:each) do
    activate_authlogic
    @current = users(:user_superuser)
    UserSession.create(@current)
  end

   it "should go to index" do
    get :index
    response.should be_success
  end

  it "should go to show" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    post :show, :id=>1
    flash[:notice].should == "Artykul szczegoly"
    response.should be_success
  end

  it "should go to new" do
    get :new
#    assigns(:article).should have(3).attachments
    response.should be_success
  end

  it "should go to create" do
    Article.stub!(:new).and_return(@article = mock_model(Article, :save=>true, :user= => true))
    post :create, :article => {:title => "nowy", :text=>'tekst'}
    assigns(:article).should_not be_nil
    flash[:notice].should == "Artykuł został dodany"
    response.should be_redirect
  end

  it "should go to create" do
    Article.stub!(:new).and_return(@article = mock_model(Article, :save=>false, :user= => true))
    post :create, :article => {:title => "nowy", :text=>'tekst'}
    assigns(:article).should_not be_nil
    flash[:notice].should == "Błąd: Nie udało się dodać artykułu"
    response.should be_success
  end

  it "should go to edit" do
    Article.stub!(:find).and_return(@article = mock_model(Article))
    post :edit, :id=>1
    response.should be_success
  end

  it "should go to update" do
    Article.stub!(:find).and_return(@article = mock_model(Article, :update_attributes=>true))
    post :update, :id=>1
    flash[:notice].should == "Artykuł został uaktualniony"
    response.should be_redirect
  end

  it "should go to destroy" do
    Article.stub!(:find).and_return(@article = mock_model(Article, :destroy=>true))
    post :destroy, :id=>1
    flash[:notice].should == "Artykuł został usunięty"
    response.should redirect_to(articles_url)
  end
end