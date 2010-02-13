class AuctionObserver < ActiveRecord::Observer
  observe :auction
  def before_destroy(model)
  #  raise "IN observer"
  end
  
end
