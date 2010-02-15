class AuctionObserver < ActiveRecord::Observer
  observe :auction
  def before_destroy(model)
  end
  def after_destroy(model)
    #raise model.bids.count.to_s
    a = ArchivalAuction.from_auction(model)
    #a.charge = model.charge
    a.save
    #a.charge.save
    if a.errors
        a.errors.each do |e|
          puts e.to_s +"\n"
        end
    end
    model.close
    chargeSum = PaymentPolitic.charge(model)
    charge = Charge.new
    charge.chargeable = a
    charge.sum = chargeSum
    charge.charges_owner = model.user
    charge.save
   # model.bids.destroy
    model.bids.each do |b|
      b.destroy
    end
     #model.bids.destroy_all
#    if(Auction.find_by_id(model.id))
#      if (a = ArchivalAuction.find_by_id(model.id))
#        a.destroy
#      end
#    end
  end
end
