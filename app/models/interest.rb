class Interest < ActiveRecord::Base
  has_and_belongs_to_many :users
  validates_uniqueness_of :name, :message => "Istnieje kategoria zainteresowań o takiej nazwie"
end
