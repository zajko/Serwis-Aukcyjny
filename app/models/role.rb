class Role < ActiveRecord::Base
  acts_as_authorization_role
  acts_as_authorization_object
  has_and_belongs_to_many :users
  #has_many :roles_users
  #has_many :users, :through => :roles_users
  before_save :de_capitalize_name
  before_update :de_capitalize_name
  named_scope :appliable, {:conditions => ["authorizable_type IS NULL"]}  
  def de_capitalize_name
    self.name = self.name.downcase
  end
  #def destroy
   #RolesUser.role_id_equals(id).destroy_all
   #super
  #end
  def self.per_page
    10 #TODO zrób tak, żeby to było w pliku konfiguracyjnym
  end
  
end
