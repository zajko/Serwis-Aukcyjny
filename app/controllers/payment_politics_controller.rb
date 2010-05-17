class PaymentPoliticsController < ApplicationController
  rescue_from Acl9::AccessDenied, :with => :deny_user_access
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
      flash[:notice] = "Polityka została utworzona."
      redirect_to :action => 'index'
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
      flash[:notice] = "Zmiany w polityce zostały zapisane."
      redirect_to @payment_politic
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @payment_politic = PaymentPolitic.find(params[:id])
    @payment_politic.destroy
    flash[:notice] = "Polityka została usunieta."
    redirect_to :action => 'index'
  end
   protected
   def deny_user_access
    @user =current_user
    if @user == nil
      flash[:notice] = "Musisz się zalogować"
      redirect_to :root
      return
    end

    if @user.has_role?(:banned)
      flash[:notice] = "Twoje konto jest zablokowane"
      redirect_to :root
      return
    end
    if @user.has_role?(:not_activated)
      flash[:notice] = "Musisz zaktywować swoje konto"
      redirect_to :root
      #TODO Tu ma się pojawić redirect do powiadomienia o tym, że trzeba zaktywować
      return
    end
    flash[:notice] = flash[:notice] ? flash[:notice] : "Nie masz uprawnień do tej części serwisu"
    redirect_to :root
    #TODO Tu ma się pojawić redirect do powiadomienia o tym, że trzeba zaktywować
    return
  end
end
