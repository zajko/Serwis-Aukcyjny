class RolesUser < ActiveRecord::Base
  set_primary_key :role_id
  set_primary_key :user_id
  validates_presence_of :user_id, :role_id
  belongs_to :user
  belongs_to :role
  validate :cannot_adminize_banned
  validate :cannot_ban_suspend_superuser
  validate :cannot_destroy_superuser, :on => :destroy
  validate :only_one_superuser, :on => :create
  def cannot_destroy_superuser
    errors.add(:s, "Nie można odebrać prawa superużtkownika") if role.name == "superuser"
  end
  def only_one_superuser
#    Zmina z RolesUser.find_by_role_id(role.id).count > 0  na RolesUser.find_by_role_id(role.id)!= nil
    errors.add(:s, "Może być tylko jeden superuser") if role.name == "superuser" and RolesUser.find_by_role_id(role.id)!= nil
  end
  def cannot_adminize_banned
   #    korekta z baned na banned
   errors.add(:s, "Nie można nadać takich ról zawieszonemu użytkownikowi") if user.has_role?(:banned) and (role.name == "admin" or role.name == "superuser")
  end
  def cannot_ban_suspend_superuser
   errors.add(:s, "Nie można nadać takich ról superuserowi") if user.has_role?(:superuser) and (role.name == "banned" or role.name == "not_activated") 
  end
#  before_create do |roles_user|
#    
#    sup = Role.find_by_name(:superuser)
#    if (role.name == "not-activated" or role.name == "banned") and user.roles.include? sup
#      roles_user.errors.add "Cannot suspend"
#      false
#    end
#  end
#  before_destroy do |roles_user|
#    if roles_user.role.name = "superuser"
#      roles_user.errors.add "Cannot remove superuser"
#      false
#    end
#  end
end
