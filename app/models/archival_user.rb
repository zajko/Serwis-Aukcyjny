class ArchivalUser < ActiveRecord::Base
    extend Searchable
  validates_uniqueness_of :login, :message => "Istnieje użytkownik o takiej nazwie"
  validates_uniqueness_of :email, :message => "Istnieje użytkownik o takim e-mailu"
  has_many :archival_auctions, :as => :acrhival_auction_owner
  has_many :archival_bids, :as => :acrhival_bid_owner
  has_many :charges, :as => :charge_owner
  has_many :payments, :as => :payment_owner
  def self.copy_attributes_between_models(from_model, to_model, options = {})
   return unless from_model && to_model
   except_list = options[:except_list] || []
   except_list << :id
   to_model.attributes.each do |attr, val|
      to_model[attr] = from_model[attr] unless !to_model.attributes.has_key?(attr) || except_list.index(attr.to_sym) || (options[:dont_overwrite] and !to_model[attr].blank?)
   end
    to_model.save if options[:save]
    to_model
  end
  
  def self.from_user(u)
    ret = ArchivalUser.new
    ArchivalUser.copy_attributes_between_models(u, ret)
    ret.user_creation_time = u.created_at
    ret.id = u.id
    return ret
  end
end
