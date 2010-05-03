class ArchivalBid < ActiveRecord::Base
  belongs_to :archival_biddable, :polymorphic => true
  belongs_to :archival_bid_owner, :polymorphic => true#, :dependent => :destroy
  #has_one :owner, :as => :acrhival_bid_owner
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
  def save
    super
  end
  def self.from_bid(u)
    ret = ArchivalBid.new
    ArchivalBid.copy_attributes_between_models(u, ret)
    ret.archival_bid_owner = u.user
    ret.bid_created_time = u.created_at
    ret.archival_biddable = u.auction
    return ret
  end
end
