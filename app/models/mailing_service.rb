class MailingService < ActiveRecord::Base
  extend Searchable
  has_one :auction, :as => :auctionable, :autosave => true
  has_many :auctions_categories, :through => :auction
  accepts_nested_attributes_for :auction, :allow_destroy => true
  validates_numericality_of :recipients_number, :greater_than => 0, :message => "Liczba odbiorców musi być większa od 0"
  validates_numericality_of :number_of_emails_to_one_recipient, :greater_than => 0, :message => "Liczba wysłanych e-maili musi być większa od 0"

  def save
    errors.add(:s, "Nie można utworzyć banneru bez aukcji.") if auction == nil

    if(errors.count == 0)
      return super
    else
      return false
    end
  end
end
