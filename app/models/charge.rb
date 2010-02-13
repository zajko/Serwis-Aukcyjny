class Charge < ActiveRecord::Base
  belongs_to :chargeable, :polymorphic => true, :dependent => :destroy
  belongs_to :charges_owner, :polymorphic => true
  #has_one :owner, :as => :charge_owner
  #belongs_to :user
  #belongs_to :archival_user
  def owner
    if user
      return user
    end
    if archival_user
      return archival_user
    end
    raise "Opłata #{id} nie związana z żadnym użytkownikiem !"
  end
end
