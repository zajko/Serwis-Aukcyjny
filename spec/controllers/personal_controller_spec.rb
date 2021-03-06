require 'spec_helper'
require "authlogic/test_case"
describe PersonalController do
  fixtures :users, :roles
  #Delete this example and add some real ones
  it "should use PersonalController" do
    controller.should be_an_instance_of(PersonalController)
  end

  def show_index
    post :index
  end

  def show_bidded
    post :index
  end

  it "should redirect when banned user wants index" do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:banned_user)
    UserSession.create(@current)
    show_index
    response.should be_redirect
  end

  it "should redirect when not_activated user wants index" do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:not_activated_user)
    UserSession.create(@current)
    show_index
    response.should be_redirect
  end

  it "should redirect to root when banned user wants index" do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:banned_user)
    UserSession.create(@current)
    show_index
    response.should redirect_to('/')
  end

  it "should redirect to root when not_activated user wants index" do
    activate_authlogic
    #User.stub!(:find).and_return(@user = mock_model(User, :save => :true))
    @current = users(:not_activated_user)
    UserSession.create(@current)
    show_index
    response.should redirect_to('/')
  end
end
