class Category < ActiveRecord::Base
  has_and_belongs_to_many :auctions
  validates_presence_of :name
  validate :name_not_trivial
  validates_uniqueness_of :name, :message => "Istnieje już kategoria o takiej nazwie"
  attr_accessible :name
  attr_accessible :id
  def name_not_trivial
    if name == nil || name.gsub(/ /,'').length == 0
      errors.add(:uwaga, "Nazwa kategorii musi być niepustym ciągiem liter i nie składać się tylko z odstępów")
      return false
    end
    return true
  end
end