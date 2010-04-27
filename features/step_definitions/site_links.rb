
# licytacja prosta
Given /^I have SiteLink auction created by (.+) with url (.+), pagerank (.+), users daily (.+), minimal price (.+), minimal bidding diff (.+)$/ do |user_name,url,pagerank,users_daily, minimal_priece, minimal_bidding_diff|

    user=User.find_by_login user_name

    siteLink = SiteLink.new
    siteLink.url = 'http://'+url
    siteLink.pagerank = pagerank
    siteLink.users_daily = users_daily
  
    auction = Auction.new
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.auctionable_id = siteLink.id
    auction.auctionable_type = "SiteLink"
    
    auction.minimal_price = minimal_priece
    auction.minimal_bidding_difference =minimal_bidding_diff

    # zostawiam asercje i komunikaty o błędach. może przy jakiś modyfikacjach się przydadzą
    assert auction.save, auction.errors.full_messages
    siteLink.auction=auction
    assert siteLink.valid?
    assert siteLink.save, siteLink.errors.full_messages
end

# kup teraz "proste"
Given /^I have SiteLink buy now auction created by (.+) with url (.+), pagerank (.+), users daily (.+), price (.+)$/ do |user_name,url,pagerank,users_daily, price|

    user=User.find_by_login user_name

    siteLink = SiteLink.new
    siteLink.url = 'http://'+url
    siteLink.pagerank = pagerank
    siteLink.users_daily = users_daily

    auction = Auction.new
    auction.user_id = user.id
    auction.start = Date.today()+1.days
    auction.auction_end=Date.today()+2.days
    auction.activated = true
    auction.auctionable_id = siteLink.id
    auction.auctionable_type = "SiteLink"
    auction.buy_now_price = price
    # zostawiam asercje i komunikaty o błędach. może przy jakiś modyfikacjach się przydadzą
    assert auction.save, auction.errors.full_messages
    siteLink.auction=auction
    assert siteLink.valid?
    assert siteLink.save, siteLink.errors.full_messages
end

# licytacja rozbudowana
Given /^I have SiteLink auction created by (.+) with url (.+), pagerank (.+), users daily (.+) minimal price (.+), minimal bidding diff (.+) which starts at (.+) and ends (.+)$/ do |user_name,url,pagerank,users_daily,minimal_price, minimal_bidding_diff, start,endd|

    user=User.find_by_login user_name

    siteLink = SiteLink.new
    siteLink.url = 'http://'+url
    siteLink.pagerank = pagerank
    siteLink.users_daily = users_daily
  
    auction = Auction.new
    auction.user_id = user.id
    auction.start = start
    auction.auction_end=endd
    auction.activated = true
    auction.auctionable_id = siteLink.id
    auction.auctionable_type = "SiteLink"
    auction.minimal_price = minimal_price
    auction.minimal_bidding_difference =minimal_bidding_diff

    # zostawiam asercje i komunikaty o błędach. może przy jakiś modyfikacjach się przydadzą
    assert auction.save, auction.errors.full_messages
    siteLink.auction=auction
    assert siteLink.valid?
    assert siteLink.save, siteLink.errors.full_messages
end


# kup teraz rozbudowane
Given /^I have SiteLink buy now auction created by (.+) with url (.+), pagerank (.+),users_daily (.+), minimal price (.+), minimal bidding diff which starts at (.+) and ends at (.+)$/ do |user_name,url, price,start,endd|

    user=User.find_by_login user_name

    siteLink = SiteLink.new
    siteLink.url = 'http://'+url
    siteLink.pagerank = 2
    siteLink.users_daily =100

    auction = Auction.new
    auction.user_id = user.id
    auction.start = start
    auction.auction_end= endd
    auction.activated = true
    auction.auctionable_id = siteLink.id
    auction.auctionable_type = "SiteLink"
    auction.buy_now_price = price

    # zostawiam asercje i komunikaty o błędach. może przy jakiś modyfikacjach się przydadzą
    assert auction.save, auction.errors.full_messages
    siteLink.auction=auction
    assert siteLink.valid?
    assert siteLink.save, siteLink.errors.full_messages
end