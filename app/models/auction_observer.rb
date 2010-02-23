class AuctionObserver < ActiveRecord::Observer
  observe :auction
  def before_destroy(model)
    a = ArchivalAuction.from_auction(model)
    a.save
  end
  def after_destroy(model)
    #raise model.bids.count.to_s
    if((a = ArchivalAuction.id_equals(model.id).first) == nil)
      raise "Błąd przy wykonywaniu before_destroy, aukcja archiwalna nie została utworzona."
    end
    #a.charge = model.charge
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
    bids = ArchivalBid.archival_biddable_id_equals(model.id).archival_biddable_type_equals("Auction")#find_by_user_id(model.id)
    bids.each do |b|
      b.archival_biddable = a
      b.save
    end
     #model.bids.destroy_all
#    if(Auction.find_by_id(model.id))
#      if (a = ArchivalAuction.find_by_id(model.id))
#        a.destroy
#      end
#    end
  end
end
