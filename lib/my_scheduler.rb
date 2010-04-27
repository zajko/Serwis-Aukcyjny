require 'rubygems'
require 'rufus/scheduler' # sudo gem install rufus-scheduler
class MyScheduler # < Tableless
@@scheduler = nil
@@auction_to_destroy = nil
@@auction_destroyer = nil

 def self.scheduler=(s)
   @@scheduler = s
 end
 def self.scheduler
   @@scheduler
 end
 def self.auction_to_destroy=(s)
   @@auction_to_destroy = s
 end
 def self.auction_to_destroy
   @@auction_to_destroy
 end
 def self.auction_destroyer=(s)
   @@auction_destroyer = s
 end
 def self.auction_destroyer
   @@auction_destroyer
 end
 
 def self.initialise()
   @@auction_to_destroy_queue = Queue.new
   if(@@scheduler)
    @@scheduler = nil
    sleep(20)
    @@scheduler.stop
   end
  @@scheduler = Rufus::Scheduler.start_new
  @@auction_destroyer = Thread.new do
      while @@scheduler != nil do
        auction = @@auction_to_destroy_queue.pop
        if(auction != nil)
          auction.close
          auction.destroy
        end
      end
    end
  #TODO z powyższego threada możnaby zrobić jakąś porządna klasę z interruptami itd
  @@scheduler.every '10s', :first_in => "10s",  :tags => 'auction_closing' do
    Auction.transaction do
      auct = Auction.expired.all
      auct.each do |a|
        @@auction_to_destroy_queue << a      
      end
    end
  end
    Rails.prep_exit do
      if(@@scheduler)
        @@scheduler.stop
        @@scheduler == nil
      end
      @@auction_to_destroy.push nil if @@auction_to_destroy
  end
  end
end