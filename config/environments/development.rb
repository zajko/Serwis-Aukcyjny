# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
#config.cache_classes = true
# Don't care if the mailer can't send
#config.action_mailer.raise_delivery_errors = false
# ActiveRecord::Base.allow_concurrency = true

#  Rails.scheduler = Rufus::Scheduler.start_new
#  
#  Rails.auction_to_destroy_queue = Queue.new
#  
#  Rails.auction_destroyer = Thread.new do
#    while Rails.scheduler
#      auction = Rails.auction_to_destroy_queue.pop
#      if(auction != nil)
#        auction.close
#      end
#    #  auction.destroy
#    end
#  end
#  #TODO z powyższego threada możnaby zrobić jakąś porządna klasę z interruptami itd
#  Rails.scheduler.every '10s', :first_in => "10s",  :tags => 'auction_closing' do
#  Auction.transaction do
#    auct = Auction.expired.all
##    Auction.delete(auct)
#    auct.each do |a|
#      Rails.auction_to_destroy_queue << a
#      #Auction.delete(a)
#      
#    end
#  end
#  
#end