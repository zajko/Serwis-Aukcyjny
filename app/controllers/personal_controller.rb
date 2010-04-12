class PersonalController < ApplicationController
  access_control do
    allow logged_in
      deny :banned, :not_activated
    end
    rescue_from Acl9::AccessDenied, :with => :deny_user_access
  
  
  def index
    if !current_user
      flash[:notice] = "Musisz się zalogować, jak tu wszedłeś ?"
      redirect_to :root
      return
    end
    @auctions = Auction.user_id_equals(current_user.id).all
#Bid.find_all_by_user_id(current_user.id)
  end

  def bidded
    if !current_user
      flash[:notice] = "Musisz się zalogować, jak tu wszedłeś ?"
      redirect_to :root
      return
    end
    bids = Bid.not_cancelled.user_id_equals(current_user.id).all.map{|x| x.auction_id}
    @auctions = Auction.id_in(bids)
  end

  def observed
    if !current_user
      flash[:notice] = "Musisz się zalogować, jak tu wszedłeś ?"
      redirect_to :root
      return
    end
    @auctions = current_user.observed
  end

  def saldo
    id = params[:id]
    if id == nil and current_user
      id = current_user.id
      #params[:id] = current_user.id
    end
    user = User.find(id)
    if(user == nil)
      user = ArchivalUser.find(id)
      if(user == nil)
        raise "nie ma takiego użyszkodnika"
      end
    end
    @user_login = user.login
    @payments = Payment.payment_owner_id_equals(id).all
    @charges = Charge.charges_owner_id_equals(id).all
    @saldo = []
    @saldo << @payments
    @saldo << @charges
    @saldo.flatten!
    if @saldo.length > 0
      @saldo.sort_by{|x| x.created_at}
    end
 end
 
 protected
  def deny_user_access
    @user =current_user
    if @user == nil
      flash[:notice] = "Musisz się zalogować"
      redirect_to :action=>"new", :controller=>"user_session"
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
