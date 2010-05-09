class AuctionObserver < ActiveRecord::Observer
  observe :auction
  def before_destroy(model)
    a = ArchivalAuction.from_auction(model)
    
    a.save
    #raise model.bids.not_cancelled.count.to_s
    model.notify_auction_winners!
    chargeSum = PaymentPolitic.charge(model)
    charge = Charge.new
    charge.chargeable = a
    charge.sum = chargeSum
    charge.charges_owner = model.user
    charge.save
    winningBids = model.winning_bids
   # model.notify_auction_owner!(winningBids, charge.sum)
  end

  def after_destroy(model)
    
    if((a = ArchivalAuction.id_equals(model.id).first) == nil)
      raise "Błąd przy wykonywaniu before_destroy, aukcja archiwalna nie została utworzona."
    end
    
    model.bids.each do |b|
      archBid = ArchivalBid.from_bid(b)
      archBid.archival_biddable = a
      archBid.save
      b.destroy
    end    
    
    if a.errors
        a.errors.each do |e|
          puts e.to_s +"\n"
        end
    end
    model.close
    bids = ArchivalBid.archival_biddable_id_equals(model.id).archival_biddable_type_equals("Auction")#find_by_user_id(model.id)
    bids.each do |b|
      b.archival_biddable = a
      b.save
    end
  end

  def after_save(model)
    count = model.bids.not_cancelled.count
    najwyzszaOferta = model.bids.not_cancelled.by_offered_price.all.first if model.bids and count >0
    najnowszaOferta = model.bids.not_cancelled.by_created_at_desc.all.first if model.bids and count >0
    if count > 1 and najwyzszaOferta and najnowszaOferta and najwyzszaOferta.id == najnowszaOferta.id # to znaczy, że nastąpiło przebicie count>1 bo jesli jest tylko jedna oferta to nie ma sensu nikogo o niczym powiadamiac ?
      model.notify_about_auction_prize_change!
    end
  end
end
