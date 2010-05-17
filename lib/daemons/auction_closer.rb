#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end
#@@auction_to_destroy_queue = Queue.new
while($running) do


  Auction.transaction do
      auct = Auction.expired.all
      auct.each do |a|
        if(a != nil)
             #ActiveRecord::Base.logger.info "SHould be teh delete at #{Time.now}.\n"
             #a.close
             begin
              a.destroy
              a.errors.each do |e|
                ActiveRecord::Base.logger.info "\n\n!!#{Time.now}   :    #{e}\n\n"
              end
             rescue Object => ex
               ActiveRecord::Base.logger.info "\n\n!!#{Time.now}   :    #{ex}\n\n"
             end
             sleep 1
        end
      end
  end
#  while(@@auction_to_destroy.empty? == false) do
#  	auction = @@auction_to_destroy_queue.pop
#	  if(auction != nil)
#	     auction.close
#	     auction.destroy
#	  end
# end
  
  sleep 10
end
