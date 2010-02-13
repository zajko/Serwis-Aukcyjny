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
