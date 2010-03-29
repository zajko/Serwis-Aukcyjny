#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class RolesUserTest < ActiveSupport::TestCase
  fixtures :users
  # Replace this with your real tests.

  def test_cannot_destroy_superuser
    user = users(:jarek1)
    role = roles(:superuser)
    roles_user = RolesUser.new
    roles_user.role_id = role.id
    roles_user.user_id = user.id
    roles_user.cannot_destroy_superuser

    assert_match(/Nie można odebrać prawa superużtkownika/, roles_user.errors.on(:s))
  end

  def test_only_one_superuser
    #    robie jarek2 jako superuser
    user2 = users(:jarek2)
    assert !user2.has_role?(:superuser)
    user2.has_role!(:superuser)
    assert user2.has_role?(:superuser)

    user = users(:jarek1)
    role = roles(:superuser)
    roles_user = RolesUser.new
    roles_user.role_id = role.id
    roles_user.user_id = user.id
    roles_user.only_one_superuser

    assert_match(/Może być tylko jeden superuser/, roles_user.errors.on(:s))
  end

  def test_cannot_adminize_banned
    user = users(:jarek2)
    assert !user.banned?
    user.ban
    assert user.banned?

    role = roles(:superuser)
    roles_user = RolesUser.new
    roles_user.role_id = role.id
    roles_user.user_id = user.id
    roles_user.cannot_adminize_banned

    assert_match(/Nie można nadać takich ról zawieszonemu użytkownikowi/, roles_user.errors.on(:s))

    role = roles(:admin)
    roles_user = RolesUser.new
    roles_user.role_id = role.id
    roles_user.user_id = user.id
    roles_user.cannot_adminize_banned

    assert_match(/Nie można nadać takich ról zawieszonemu użytkownikowi/, roles_user.errors.on(:s))
  end

  def test_cannot_ban_suspend_superuser
    user = users(:jarek2)
    assert !user.has_role?(:superuser)
    !user.has_role!(:superuser)
    assert user.has_role?(:superuser)
    
    role = roles(:banned)
    roles_user = RolesUser.new
    roles_user.role_id = role.id
    roles_user.user_id = user.id
    roles_user.cannot_ban_suspend_superuser

    assert_match(/Nie można nadać takich ról superuserowi/, roles_user.errors.on(:s))

    role = roles(:not_activated)
    roles_user = RolesUser.new
    roles_user.role_id = role.id
    roles_user.user_id = user.id
    roles_user.cannot_ban_suspend_superuser

    assert_match(/Nie można nadać takich ról superuserowi/, roles_user.errors.on(:s))
  end

  def test_rola_superuser_exist
    assert Role.find_by_name("superuser")
  end
  
  def test_superuser_cant_not_activated
    user = users(:user_superuser)
    assert !user.has_role?(:not_activated)
    assert user.has_role?(:superuser)
    user.has_role!(:not_activated)
    assert !user.has_role?(:not_activated)
  end
  
  def test_superuser_cant_banned
    user = users(:user_superuser)
    assert !user.banned?
    user.ban
    assert !user.banned?
  end
  
#  def test_not_activated_superuser
#    rola = create_rola('superuser')
#    user = create_user()
#    
#    assert user.has_role?(:not_activated)
#    user.has_no_role!(:not_activated)
#    assert !user.has_role?(:not_activated)    
#    assert user.update
#    
#    
#    assert !user.has_role?(:superuser)
#    user.has_role!(:superuser)
#    assert user.has_role?(:superuser)
#    assert user.update
#    user.has_role!(:not_activated)
#    assert !user.update, user.errors.full_messages
#  end
#  
#  def test_not_present_user_or_role
#    assert !Role.find_by_name("superuser")
#    rola = Role.new
#    rola.name = "superuser"
#    assert rola.save
#    assert Role.find_by_name("superuser")
#    user = User.new
#    user.login = "jakistaki"
#    user.email = "jakotaki@example.com"
#    user.password = 'nowe'
#    user.password_confirmation = 'nowe'
#    assert user.valid?, user.errors.full_messages
#    assert user.save
#    
#    ru = RolesUser.new
#    assert !ru.save
#    ru.user_id = user.id
#    assert !ru.save
#    ru.role_id = Role.find_by_name("superuser").id
#    assert ru.save, ru.errors.full_messages
#  end
#  
#  def test_cant_band_superuser
#    assert !Role.find_by_name("superuser")
#    rola = Role.new
#    rola.name = "superuser"
#    assert !Role.find_by_name("superuser")
#    assert rola.save
#    assert Role.find_by_name("superuser")
#    user = User.new
#    user.login = "jakistaki"
#    user.email = "jakotaki@example.com"
#    user.password = 'nowe'
#    user.password_confirmation = 'nowe'
#    assert user.valid?, user.errors.full_messages
#    user.save
#    
#    ru = RolesUser.new
#    assert !ru.save
#    ru.user_id = user.id
#    assert !ru.save
#    ru.role_id = Role.find_by_name("superuser").id
#    assert ru.save, ru.errors.full_messages
#    
#    #now I try to put  ban on a user
#    ruBan = RolesUser.new
#    ru.user_id = 
#    
#    RolesUser 
#  end
#  
#  def test_banned_superuser
#    rolaUser = RolesUser.new
#    assert !rolaUser.valid?
#    assert !rolaUser.save
#    user = User.new
#    user.login = "jakistaki"
#    user.email = "jakotaki@example.com"
#    user.password = 'nowe'
#    user.password_confirmation = 'nowe'
#    assert user.valid?, user.errors.full_messages
#    user.save
#    
#    assert !user.has_role?(:superuser)
#    user.has_role!(:superuser)
#    assert user.has_role?(:superuser)
#    assert !user.banned?
#    user.ban
#    b = user.roles_users(:banned)
#    assert b.save
#    assert !user.banned?
#  end
#  
#  def test_not_activated_ban_when_not_superuser
#    user = User.new
#    user.login = "jakistaki"
#    user.email = "jakotaki@example.com"
#    user.password = 'nowe'
#    user.password_confirmation = 'nowe'
#    assert user.valid?, user.errors.full_messages
#    
#    assert !user.banned?
#    user.ban
#    assert user.banned?
#    assert !user.has_role?(:not_activated)
#    user.has_role!(:not_activated)
#    assert user.has_role?(:not_activated)
#
#    assert user.valid?, user.errors.full_messages
#    assert user.save
#  end
 
  def test_destroy_superuser
    user = User.new
    user.login = "jakistaki"
    user.email = "jakotaki@example.com"
    user.password = 'nowe'
    user.password_confirmation = 'nowe'
    assert user.valid?, user.errors.full_messages
    
    assert !user.has_role?(:superuser)
    user.has_role!(:superuser)
    assert user.has_role?(:superuser), user.errors.full_messages
    user.has_no_role!(:superuser)
    assert user.has_role?(:superuser)
  end
  
  protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end
  
  def create_rola(jaka)
    rola = Role.new
    rola.name = jaka
    rola.save
    rola
  end
end
