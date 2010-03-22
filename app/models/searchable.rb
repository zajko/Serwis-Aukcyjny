module Searchable
   def prepare_search_scopes(params = {})
    #Kernel.const_get(product_type.classify).new(params[product_type.to_s])
    
    scope = self.scoped({})#search(:all)#Auction.search(:auctionable_type => params[:product_type].classify, :activated => true)
 
    if (scope == nil || scope.count == 0)
      return nil
    end
    if(params == nil)
      return scope
    end
    params.each do |key, value|
      #if self.respond_to?(key) || (key.to_s.include?("auction_") && Auction.respond_to?(key.to_s.gsub(/auction_/,'')))
      begin
        scope = scope.send(key.to_s, value) if value != nil && value != ""
      rescue NoMethodError => e
      end
      #end
    end


    begin
      if(params != nil and params[:categories_attributes] != nil)
        temp = params[:categories_attributes].map {|t| t.to_i}
        if(temp != nil && temp.size > 0)
          scope = scope.by_categories_id(*temp)
        end
      end
    rescue NoMethodError => e
    end

    scope = scope.order_scope( params[:order_by] ) if params[:order_by] && self.all.first.attributes.has_key? (params[:order_by].split(' ')[0])
    if scope.respond_to?(:order_auction_scope) then
      scope = scope.order_auction_scope ( params[:order_by] ) if params[:order_by] && Auction.all.first.attributes.has_key? (params[:order_by].split(' ')[0])
    end
    return scope
  end
end