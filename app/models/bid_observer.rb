class BidObserver < ActiveRecord::Observer
  observe :bid
    @@minimal_end_of_auction_interval = 180 #TODO Zrob z tego configa
  def after_create(model)
    #model.auction.current_price = model.auction.calculate_current_price
  end
  def after_delete(model)
    model.auction.current_price = model.auction.calculate_current_price
    model.auction.save
  end
  def after_save(model)
    
    model.auction.current_price = model.auction.calculate_current_price
    update_auction_time model
    if(!model.auction.save)
      
    end
  end
  def after_update(model)
    model.auction.current_price = model.auction.calculate_current_price
    model.auction.save
  end
  
  def update_auction_time(model)
    Auction.transaction do
      #a = Auction.find(self.auction_id)
      if ( model.auction.auction_end - Time.now <= @@minimal_end_of_auction_interval)
        t = Time.now.advance(:seconds => @@minimal_end_of_auction_interval)
        #TODO zastanowic sie nad localtimem - trzeba poprawic tak zeby wszedzie sie wyswietlal i dodawal localtime !
        if model.auction.update_attribute :auction_end, t
        else
          model.errors_to_base("Auckja już zamknięta lub utracono połączenie z bazą !")
          false
        end
      end
    end
  end
end
