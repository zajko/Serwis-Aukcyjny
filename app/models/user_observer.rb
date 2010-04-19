class UserObserver < ActiveRecord::Observer
  def before_destroy(model)
    a = ArchivalUser.from_user(model)
   
    a.save
   
      if a.errors
        x = ""
        a.errors.each do |e|
          x = x + e.to_s + "\n"
        end
        puts x
      end
      
  end
  def after_destroy(model)
    if model == nil or model.id.blank?
      raise "Został usunięty użytkownik bez id ?"
    end
      #if(User.find(model.id))  # Tten if to jest jakis powazny edufail, nie wiem czemu to napisalem :P
      #  if (archival = ArchivalUser.id_equals(model.id))
      #    archival.destroy
      #  end
      #else
      if( (archival = ArchivalUser.id_equals(model.id).first) == nil)
        raise "Błąd przy wykonywaniu before_destroy, użytkownik archiwalny nie został utworzony."
      end
        auctions = ArchivalAuction.archival_auction_owner_id_equals(model.id).archival_auction_owner_type_equals("User")
        auctions.each do |a|
          #a.archival_user_id = a.user_id
          #a.user_id = nil
          a.archival_auction_owner = archival
          a.save
        end
        bids = ArchivalBid.archival_bid_owner_id_equals(model.id).archival_bid_owner_type_equals("User")#find_by_user_id(model.id)
        bids.each do |b|
          #b.archival_user_id = b.user_id
          #b.user_id = nil
          b.archival_bid_owner = archival
          b.save
        end
        charges = Charge.charges_owner_id_equals(model.id).charges_owner_type_equals("User")#user_id_equals(model.id)#find_by_user_id(model.id)
        charges.each do |charge|
          charge.charges_owner = archival#archival_user_id = charge.user_id
          #charge.user_id = nil
          charge.save
        end
        payments = Payment.payment_owner_id_equals(model.id).payment_owner_type_equals("User")#user_id_equals(model.id)#find_by_user_id(model.id)
        payments.each do |payment|
          payment.payment_owner = archival#archival_user_id = payment.user_id
         # payment.user_id = nil
          payment.save
        end      
  end
end
