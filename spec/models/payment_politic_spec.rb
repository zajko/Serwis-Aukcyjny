# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../spec_helper'

describe PaymentPolitic do
  fixtures :site_links, :sponsored_articles, :bids, :users, :payment_politics

  def create_auction(prices = [100, 200])
     @bid1 = mock_model(Bid, {:offered_price => 300, :user => users(:user_2), :cancelled => false})
     @bid2 = mock_model(Bid, {:offered_price => 120, :user => users(:user_2), :cancelled => false})
     @bids = mock_model(Array, {:not_cancelled => [@bid1, @bid2]})
     @auction = mock_model(Auction, {:bids => @bids, :winning_prices => prices})
    
  end

  it "should calculate payments from one winning_price" do
    create_auction([700])
    PaymentPolitic.charge(@auction).should== 60.5
  end

  it "should calculate payments from multiple winning_prices" do
    create_auction
    PaymentPolitic.charge(@auction).should== 32
  end

end

