module ProductsHelper
 require 'uri'
require 'open-uri'
  def categorized(i)
      if @product
         @product.auction.categories.include?(i)
      else
        false
      end
  end
  
  def ProductsHelper.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end



    def activate_url(auction_id)
      "http://" + request.env['HTTP_HOST'] + url_for(:controller => 'products', :action => 'activate', :id => auction_id)
    end



    def to_parse(i)
require "uri"
require "net/http"
res = Net::HTTP.post_form(URI.parse('http://checksitetraffic.com/index.php'), {"dom" => i,"pv" => "10","crt"=>"1","ppc"=>"0.1","Check" => "submit"})
puts res.body

#calosc
String x = res.body
pierwsze = x.index("Daily unique visitors:")
ostatnie = x.index("Income per month from AdSense")+90


 #do obrobki
 obrobka = x[pierwsze..ostatnie]
 do_1=obrobka.index("Page")-1
# Daily unique visitors:
unique_visitors = obrobka[23..do_1-4]

# step2 = obrobka[do_1..ostatnie]
# do_2=step2.index("Clicks")-1
# # Page views per day:
# views_day= step2[21..do_2]
#
# step3 = step2[do_2..ostatnie]
# do_3=step3.index("Income")-1
# #Clicks per day (CTR: 1%):
# per_day= step3[27..do_3]
#
# step4 = step3[do_3+10..ostatnie]
# do_4 = step4.index("Income")
# #Income per day from AdSense (0.1$ per click):
# adSense_per_day = step4[37..do_4-6]
#
# step5 = step4[do_3+10..ostatnie]
# do_5 = step5.index("Income")
# #Income per month from AdSense (0.1$ per click):
# adSense_month_day = step5[54..ostatnie]

    #  return unique_visitors
     a= unique_visitors
     return a.gsub(/,/, '')
 end


require "net/http"
   def initialize(uri)
      @uri = uri
    end

   def m()
     0x100000000
   end

   def m1(a,b,c,d)
     (((a+(m-b)+(m-c))%m)^(d%m))%m # mix/power mod
   end

   def i2c(i)
     [i&0xff, i>>8&0xff, i>>16&0xff, i>>24&0xff]
   end

   def c2i(s,k=0)
     ((s[k+3].to_i*0x100+s[k+2].to_i)*0x100+s[k+1].to_i)*0x100+s[k].to_i
   end

   def mix(a,b,c)
     a = a%m; b = b%m; c = c%m;
     a = m1(a,b,c, c >> 13); b = m1(b,c,a, a <<  8); c = m1(c,a,b, b >> 13)
     a = m1(a,b,c, c >> 12); b = m1(b,c,a, a << 16); c = m1(c,a,b, b >>  5)
     a = m1(a,b,c, c >>  3); b = m1(b,c,a, a << 10); c = m1(c,a,b, b >> 15)
     [a, b, c]
   end

   def old_cn(iurl = 'info:' + @uri)
     a = 0x9E3779B9; b = 0x9E3779B9; c = 0xE6359A60
     len = iurl.size
     k = 0
     while (len >= k + 12) do
       a += c2i(iurl,k); b += c2i(iurl,k+4); c += c2i(iurl,k+8)
       a, b, c = mix(a, b, c)
       k = k + 12
     end
     a += c2i(iurl,k); b += c2i(iurl,k+4); c += (c2i(iurl,k+8) << 8) + len
     a,b,c = mix(a,b,c)
     return c
   end

   def cn
     ch = old_cn
     ch = ((ch/7) << 2) | ((ch-(ch/13).floor*13)&7)
     new_url = []
     20.times { i2c(ch).each { |i| new_url << i }; ch -= 9 }
     ('6' + old_cn(new_url).to_s).to_i
   end

   def request_uri
     # http://www.bigbold.com/snippets/posts/show/1260 + _ -> %5F
     "http://toolbarqueries.google.com/search?client=navclient-auto&hl=en&ch=#{cn}&ie=UTF-8&oe=UTF-8&features=Rank&q=info:#{URI.escape(@uri,
/[^-.!~*'()a-zA-Z\d]/)}"
   end

   def page_rank(uri = @uri)
     @uri = uri if uri != @uri
     open(request_uri) { |f| return $1.to_i if f.string =~ /Rank_1:\d:(\d+)/ }
     nil
   end

  private :m1, :i2c, :c2i, :mix, :old_cn
   attr_accessor :uri

 end
#
#if __FILE__ == $0 and 1 == ARGV.size
# puts SEO::GooglePR.new(ARGV[0]).page_rank
#end



