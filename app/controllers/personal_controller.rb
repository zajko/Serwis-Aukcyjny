class PersonalController < ApplicationController
  access_control do
    allow logged_in
      deny :banned, :not_activated
    end
    rescue_from Acl9::AccessDenied, :with => :deny_user_access


  def created_auctions
    @tab=params[:tab]
    if !current_user
      flash[:notice] = "Musisz się zalogować, jak tu wszedłeś ?"
      redirect_to :root
      return
    end
    if params[:tab]=="notactivated"
        @auctions = Auction.find(:all,:conditions=>"activated=false AND user_id="+current_user.id.to_s)
    elsif params[:tab]=="closed"
      @auctions = Auction.find(:all,:conditions=>"auction_end<'"+Date.today.to_s+"'  AND user_id='"+current_user.id.to_s+"'")
    else
      @auctions = Auction.find(:all,:conditions=>"activated=true AND auction_end<'"+Date.today.to_s+"' AND user_id="+current_user.id.to_s)
    end

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
 def bids
    if !current_user
      flash[:notice] = "Musisz się zalogować, jak tu wszedłeś ?"
      redirect_to :root
      return
    end
#    @auctions = Bid.find_all_by_user_id current_user

    @auctions = Bid.find_by_sql "SELECT b.auction_id, a.auctionable_type, a.current_price, MAX(b.offered_price) AS \"offered_price\", a.auctionable_id FROM auctions a
    INNER JOIN bids b
    ON a.id=b.auction_id
    WHERE b.user_id="+current_user.id.to_s+"
    GROUP BY b.auction_id, a.auctionable_type, a.current_price, a.auctionable_id
    ORDER BY b.auction_id";
      #  @auctions = Auction.user_id_equals(current_user.id).all
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
