class PersonalBidsController < ApplicationController
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
#    @auctions = Bid.find_all_by_user_id current_user

    @auctions = Bid.find_by_sql "SELECT b.auction_id, a.auctionable_type, a.current_price, MAX(b.offered_price) AS \"offered_price\", a.auctionable_id FROM auctions a
INNER JOIN bids b
ON a.id=b.auction_id
WHERE b.user_id="+current_user.id.to_s+"
GROUP BY b.auction_id, a.auctionable_type, a.current_price, a.auctionable_id
ORDER BY b.auction_id";

   
  #  @auctions = Auction.user_id_equals(current_user.id).all
    
  end

end
