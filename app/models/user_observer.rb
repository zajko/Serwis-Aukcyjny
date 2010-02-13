class UserObserver < ActiveRecord::Observer
  def before_destroy(model)
    a = ArchivalUser.from_auction(model)
      a.save  
      if a.errors
        a.errors.each do |e|
          puts e.to_s +"\n"
        end
      end
  end
  def after_destroy(model)
      #raise "IN observer2"
      
      if(User.find_by_id(model.id))
        if (a = ArchivalUser.find_by_if(model.id))
          a.destroy
        end
      else
        auctions = ArchivalAuction.find_by_user_id(model.id)
        auctions.each do |a|
          #a.archival_user_id = a.user_id
          #a.user_id = nil
          a.owner = a
          a.save
        end
        bids = ArchivalBid.find_by_user_id(model.id)
        bids.each do |b|
          #b.archival_user_id = b.user_id
          #b.user_id = nil
          b.owner = a
          b.save
        end
        charges = Charge.find_by_user_id(model.id)
        charges.each do |charge|
          charge.archival_user_id = charge.user_id
          charge.user_id = nil
          charge.save
        end
        payments = Payment.find_by_user_id(model.id)
        payments.each do |payment|
          payment.archival_user_id = payment.user_id
          payment.user_id = nil
          payment.save
        end
        
      end
  end
end
