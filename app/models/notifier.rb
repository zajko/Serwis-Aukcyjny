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
    :user_name => "",
    :password => ""
  }

  
  def password_reset_instructions(user)
    subject       "Password Reset Instructions"  
    from          "Binary Logic Notifier "  
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => ("http://" + default_url_options[:host] + "/password_resets/edit/" + user.perishable_token)
    #edit_password_reset_url(user.perishable_token)
  end
  
end