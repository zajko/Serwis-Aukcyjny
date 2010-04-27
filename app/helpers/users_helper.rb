module UsersHelper
  def interest(i)
      if @customer
         @customer.interests.include?(i)
      else
        false
      end
   end
end
