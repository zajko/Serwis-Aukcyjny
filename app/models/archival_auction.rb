class ArchivalAuction < ActiveRecord::Base
  has_many :archival_bids, :as => :archival_biddable
  has_one :charge, :as => :chargeable
  #has_one :owner, :as => :acrhival_auction_owner
  belongs_to :archival_auction_owner, :polymorphic => true#, :dependent => :destroy
  def self.copy_attributes_between_models(from_model, to_model, options = {})
   return unless from_model && to_model
   except_list = options[:except_list] || []
   #except_list << :id
   to_model.attributes.each do |attr, val|
      to_model[attr] = from_model[attr] unless !to_model.attributes.has_key?(attr) || except_list.index(attr.to_sym) || (options[:dont_overwrite] and !to_model[attr].blank?)
   end
    to_model.save if options[:save]
    to_model
  end

  def self.from_auction(u)
    ret = ArchivalAuction.new
    ArchivalAuction.copy_attributes_between_models(u, ret)
    ret.auction_created_time = u.created_at
    ret.id = u.id
    ret.archival_auction_owner = u.user
    #ret.user_id = u.user_id
#    u.bids.each do |b|
#      archBid = ArchivalBid.from_bid(b)
#      ret.archival_bids << archBid
#    end
    return ret
  end
  
  def self.prepare_search_scopes(params = {})
    scope = ArchivalAuction.scoped({})
    if(scope == nil || params == nil)
      return scope
    end
    begin
      scope = scope.auction_end_gte(params[:auction_end_gte]) if params[:auction_end_gte] and Date.parse(params[:auction_end_gte])
    rescue 
      scope = scope
    end
    begin
      scope = scope.auction_end_gte(params[:auction_end_lte]) if params[:auction_end_lte] and Date.parse(params[:auction_end_lte])
    rescue 
      scope = scope
    end
    
    begin
      scope = scope.current_price_gte(params[:current_price_gte].to_i) if params[:current_price_gte] && params[:current_price_gte].to_i > 0
      scope = scope.current_price_lte(params[:current_price_lte].to_i) if params[:current_price_lte].to_i > 0
      scope = scope.current_price_gte(params[:minimal_price_gte].to_i) if params[:minimal_price_gte].to_i > 0
      scope = scope.current_price_lte(params[:minimal_price_lte].to_i) if params[:minimal_price_lte].to_i > 0
    rescue
      scope = scope
    end
    return scope
  end
  
end
