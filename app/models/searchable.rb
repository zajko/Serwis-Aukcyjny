module Searchable
  
   def prepare_search_scopes(params = {})
    scope = self.scoped({})
 
    if (scope == nil || scope.count == 0)
      return nil
    end
    if(params == nil)
      return scope
    end

    params.each do |key, value|
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
    
    scope = scope.order_scope(params[:order_by] ) if params[:order_by] && self.all.first.attributes.has_key?(params[:order_by].split(' ')[0])
    if  scope.respond_to?(:order_auction_scope) then # params[:categories_attributes] == nil and
      scope = scope.order_auction_scope(params[:order_by] ) if params[:order_by] && Auction.all.first != nil && Auction.all.first.attributes.has_key?(params[:order_by].split(' ')[0])
    end
    return scope
  end
end