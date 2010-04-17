class Notifier < ActionMailer::Base
  default_url_options[:host] = "kram-reklam.pl"
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.default_charset = "utf-8"
  ActionMailer::Base.default_content_type = "text/html"
ActionMailer::Base.smtp_settings = {
    :enable_starttls_auto => true,
    :address => "smtp.gmail.com",
    :port => "587",
    :domain => "kram-reklam.pl",
    :authentication => :plain,
    :user_name => "ja.zajko",
    :password => "!iro1488"
  }

  def auction_activation_instructions(auction)    
    subject     "Instrukcje do aktywacji konta"
    from       "Kram-Reklam"
    recipients auction.user.email
    sent_on    Time.now
    body        :auctionable_url => auction.auctionable.url, 
      :auction_url => ("http://" + default_url_options[:host] + "/products/"+auction.id.to_s+"?product_type="+auction.auctionable.class.to_s.underscore ),
      :auction_activate_url => ("http://" + default_url_options[:host] + "/products/activate?[id]=" + auction.id.to_s),
      :auction_activation_token => auction.activation_token
  end
  
  def password_reset_instructions(user)
    subject       "Instrukcje do zmiany hasła"
    from          "Kram-Reklam "
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => ("http://" + default_url_options[:host] + "/password_resets/edit/" + user.perishable_token)
    #edit_password_reset_url(user.perishable_token)
  end
  
end