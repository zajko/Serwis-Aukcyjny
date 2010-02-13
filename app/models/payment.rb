class Payment < ActiveRecord::Base
  belongs_to :payable, :polymorphic => true, :dependent => :destroy
  belongs_to :payment_owner, :polymorphic => true#, :dependent => :destroy
  #has_one :powner, :as => :payment_ower
  def owner
    if user
      return user
    end
    if archival_user
      return archival_user
    end
    raise "Zapłata #{id} nie związana z żadnym użytkownikiem !"
  end
end
