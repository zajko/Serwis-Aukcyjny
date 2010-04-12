# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'factory_girl'

Factory.define :user do |u|
    u.sequence(:login) { |n| "testowy_#{n}"}
    u.email {|a| "#{a.login}@example.com".downcase }
    u.password "1234"
    u.password_confirmation {|u| u.password}
  end


#
#Factory.define :auction do |auction|
#    auction = Auction.new
#    auction.user_id = user.id
#    auction.start = Date.today()+1.days
#    auction.auction_end=Date.today()+2.days
#    auction.activated = true
#    auction.auctionable_id = siteLink.id
#    auction.auctionable_type = "SiteLink"
#
#    auction.minimal_price = minimal_priece
#    auction.minimal_bidding_difference =minimal_bidding_diff
#end