class ArchivalUser < ActiveRecord::Base
    extend Searchable
  validates_uniqueness_of :login, :message => "Istnieje użytkownik o takiej nazwie"
  validates_uniqueness_of :email, :message => "Istnieje użytkownik o takim e-mailu"
  has_many  :archival_auctions, :as => :archival_auction_owner
  has_many :archival_bids, :as => :archival_bid_owner
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
  def save
    archival_auctions.each do |a|
      a.save
    end
    archival_bids.each do |b|
        b.save
    end
    charges.each do c
      c.save
    end
    payments.each do p
      p.save
    end
    
    super
  end
  def self.from_user(model)
    
    archival = ArchivalUser.new
    
    ArchivalUser.copy_attributes_between_models(model, archival)
    
    archival.user_creation_time = model.created_at
    archival.id = model.id
    if model == nil or model.id.blank?
      raise "Został usunięty użytkownik bez id ?"
    end
   
#      auctions = ArchivalAuction.archival_auction_owner_id_equals(model.id)#.archival_auction_owner_type_equals("User")
#
#      auctions.each do |a|
#       # archival_auction = ArchivalAuction.from_auction(a)
#
#        a.archival_auction_owner = archival
#        #a.save
#        #raise "TTT3"
#      end
#
#      bids = ArchivalBid.all#archival_bid_owner_id_equals(model.id)#.archival_bid_owner_type_equals("User")#find_by_user_id(model.id)
#
#      bids.each do |b|
#        b.archival_bid_owner = archival
#        b.save
#      end
#
#      charges = model.charges#Charge.charges_owner_id_equals(model.id).charges_owner_type_equals("User")#user_id_equals(model.id)#find_by_user_id(model.id)
#      charges.each do |charge|
#        charge.charges_owner = archival#archival_user_id = charge.user_id
#        charge.user_id = nil
#        charge.save
#      end
#
#      payments = model.payments#Payment.payment_owner_id_equals(model.id).payment_owner_type_equals("User")#user_id_equals(model.id)#find_by_user_id(model.id)
#      payments.each do |payment|
#        payment.payment_owner = archival#archival_user_id = payment.user_id
#        payment.user_id = nil
#        payment.save
#      end
    return archival
  end
end
