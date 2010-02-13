class PaymentPoliticsController < ApplicationController
  def index
    @payment_politics = PaymentPolitic.all
  end
  
  def show
    @payment_politic = PaymentPolitic.find(params[:id])
  end
  
  def new
    @payment_politic = PaymentPolitic.new
  end
  
  def create
    @payment_politic = PaymentPolitic.new(params[:payment_politic])
    if @payment_politic.save
      flash[:notice] = "Successfully created payment politic."
      redirect_to @payment_politic
    else
      render :action => 'new'
    end
  end
  
  def edit
    @payment_politic = PaymentPolitic.find(params[:id])
  end
  
  def update
    @payment_politic = PaymentPolitic.find(params[:id])
    if @payment_politic.update_attributes(params[:payment_politic])
      flash[:notice] = "Successfully updated payment politic."
      redirect_to @payment_politic
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @payment_politic = PaymentPolitic.find(params[:id])
    @payment_politic.destroy
    flash[:notice] = "Successfully destroyed payment politic."
    redirect_to payment_politics_url
  end
end
