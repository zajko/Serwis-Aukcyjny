require File.dirname(__FILE__) + '/../spec_helper'
require "authlogic/test_case"

describe PaymentPoliticsController, "user not login" do

  it "should go to index" do
    get :index
    response.should be_success
  end

  it "should go to show" do
    PaymentPolitic.stub!(:find).and_return(@paymentPolitic = mock_model(PaymentPolitic))
    get :show, :id=>@paymentPolitic.id
    response.should be_success
  end

  it "should not go to new" do
    get :new
    response.should be_success
  end

  it "should go to create" do
    PaymentPolitic.stub!(:new).and_return(@paymentPolitic = mock_model(PaymentPolitic, :save=>true))
    post :create, :payment_politic=>{}
    flash[:notice].should == "Successfully created payment politic."
    response.should be_redirect
  end

   it "should go to create, create fail" do
    PaymentPolitic.stub!(:new).and_return(@paymentPolitic = mock_model(PaymentPolitic, :save=>false))
    post :create, :payment_politic=>{}
    response.should be_success
  end

  it "should go to edit" do
    PaymentPolitic.stub!(:find).and_return(@paymentPolitic = mock_model(PaymentPolitic))
    get :edit, :id=>@paymentPolitic.id
    response.should be_success
  end

  it "should go to update" do
    PaymentPolitic.stub!(:find).and_return(@paymentPolitic = mock_model(PaymentPolitic, :update_attributes=>true))
    put :update, :id=>@paymentPolitic.id
    flash[:notice].should == "Successfully updated payment politic."
    response.should be_redirect
  end

  it "should go to update, update fail" do
    PaymentPolitic.stub!(:find).and_return(@paymentPolitic = mock_model(PaymentPolitic, :update_attributes=>false))
    put :update, :id=>@paymentPolitic.id
    response.should be_success
  end

  it "should go to destroy" do
    PaymentPolitic.stub!(:find).and_return(@paymentPolitic = mock_model(PaymentPolitic, :destroy=>true))
    delete :destroy, :id=>@paymentPolitic.id
    flash[:notice].should == "Successfully destroyed payment politic."
    response.should redirect_to(payment_politics_url)
  end
end

