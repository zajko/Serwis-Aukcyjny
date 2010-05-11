require File.dirname(__FILE__) + '/../spec_helper'
require "authlogic/test_case"

describe PasswordResetsController, "user not login" do
 
  it "should go to new" do
    get :new
    response.should be_success
  end

   it "should go to edit" do
    User.stub!(:find).and_return(@user = mock_model(User))
    get :edit, :id=>@user.id
    response.should be_success
  end


  it "should go to create" do
    User.stub!(:find_by_email).and_return(@user = mock_model(User, :deliver_password_reset_instructions! =>true))
    post :create, :emai=>"jarek.fuczko@gmail.com"
    flash[:notice].should == "Wysłano instrukcje dotyczące odzyskiwania hasła. Proszę sprawdzić podaną skrzynkę pocztową."
    response.should redirect_to(root_url)
  end

  it "should go to create, non user find" do
    User.stub!(:find_by_email).and_return(@user = nil)
    post :create, :emai=>"jarek.fuczko@gmail.com"
    response.should be_success
  end

   it "should go to update, set new password" do
    User.stub!(:find_using_perishable_token).and_return(@user = mock_model(User, :save=>true, :password= =>true, :password_confirmation= =>true))
    put :update, :user=>{:password=>'nowe', :password_confirmation=>'nowe'}
    flash[:notice].should == "Hasło zostało zaktualizowane"
    response.should redirect_to(root_url)
  end

  it "should go to update, set new password failed" do
    User.stub!(:find_using_perishable_token).and_return(@user = mock_model(User, :save=>false, :password= =>true, :password_confirmation= =>true))
    put :update, :user=>{:password=>'nowe', :password_confirmation=>'nowe'}
    flash[:notice].should == "Wystąpił błąd przy aktualizacji hasła"
    response.should be_success
  end

  it "should load_user_using_perishable_token failed" do
    User.stub!(:find_using_perishable_token).and_return(@user = nil)
    put :update, :user=>{:password=>'nowe', :password_confirmation=>'nowe'}
    flash[:notice].should == "Bardzo nam przykro, ale nie możemy zlokalizować podanego konta. Spróbuj skopiować podany w e-mailu link aktywacyjny do przeglądarki, lub rozpocznij proces odzyskiwania hasła od początku"
    response.should redirect_to(root_url)
  end

end

describe PasswordResetsController, "user login" do
fixtures :users, :roles
  before(:each) do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:user_1)
    UserSession.create(@current)
  end

  it "should not go to new" do
    get :new
    flash[:notice].should == "Musisz być wylogowany"
    response.should redirect_to(account_url)
  end

   it "should go to edit" do
    User.stub!(:find_using_perishable_token).and_return(@user = mock_model(User))
    get :edit, :id=>@user.id
    flash[:notice].should == "Musisz być wylogowany"
    response.should redirect_to(account_url)
  end


  it "should go to create" do
    User.stub!(:find_by_email).and_return(@user = mock_model(User, :deliver_password_reset_instructions! =>true))
    post :create, :emai=>"jarek.fuczko@gmail.com"
    flash[:notice].should == "Musisz być wylogowany"
    response.should redirect_to(account_url)
  end

  it "should go to create, non user find" do
    User.stub!(:find_by_email).and_return(@user = nil)
    post :create, :emai=>"jarek.fuczko@gmail.com"
    flash[:notice].should == "Musisz być wylogowany"
    response.should redirect_to(account_url)
  end

   it "should go to update, set new password" do
    User.stub!(:find_using_perishable_token).and_return(@user = mock_model(User, :save=>true))
    put :update, :user=>{:password=>'nowe', :password_confirmation=>'nowe'}
    flash[:notice].should == "Musisz być wylogowany"
    response.should redirect_to(account_url)
  end

  it "should go to update, set new password failed" do
    User.stub!(:find_using_perishable_token).and_return(@user = mock_model(User, :save=>false))
    put :update, :user=>{:password=>'nowe', :password_confirmation=>'nowe'}
    flash[:notice].should == "Musisz być wylogowany"
    response.should redirect_to(account_url)
  end

  it "should load_user_using_perishable_token failed" do
    User.stub!(:find_using_perishable_token).and_return(@user = nil)
    put :update, :user=>{:password=>'nowe', :password_confirmation=>'nowe'}
    flash[:notice].should == "Bardzo nam przykro, ale nie możemy zlokalizować podanego konta. Spróbuj skopiować podany w e-mailu link aktywacyjny do przeglądarki, lub rozpocznij proces odzyskiwania hasła od początku"
    response.should redirect_to(root_url)
  end

  
end

