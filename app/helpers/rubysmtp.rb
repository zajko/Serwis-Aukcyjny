require 'net/smtp' 
  class RubySMTP
#unloadable
  attr_accessor :smtp_host, :from, :from_alias, :to, :to_alias, :subject, :message

  def initialize()
  end

  def send()
    if @from and @to and @subject and @message then
      if address_valid?(@from) and address_valid?(@to) then
        send_email()
        puts 'message sent!'
      else
        puts 'invalid email address'
      end
    else
      puts 'blank value not allowed here, check inputs'
    end
  end

  #private

  def address_valid?(address)
    address.match(/^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/).is_a? MatchData
  end

  def send_email()
    msg = <<END_OF_MESSAGE
From: #{@from_alias ? @from_alias + ' <' + @from + '>' : @from }
To: #{@to_alias ? @to_alias + ' <' + @to + '>' : @to }
Subject: #{@subject}

#{@message}
END_OF_MESSAGE

    Net::SMTP.start(@smtp_host) do |smtp|
      smtp.send_message msg, @from, @to
    end
  end

end
