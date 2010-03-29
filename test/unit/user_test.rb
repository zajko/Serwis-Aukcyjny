#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'


class UserTest < ActiveSupport::TestCase
  fixtures :users

  should_have_named_scope 'by_interests_id(1,2)', :include => :interests,
      :conditions => ["interests.id IN (?)", [1,2]]
  should_have_named_scope 'by_roles_id(1,2,3)', :include => :roles,
      :conditions => ["roles.id IN (?)", [1,2,3]]
    
  def test_truth
    assert true
  end
  def test_create
    user = User.new
    assert_not_nil(user, message = "object not created")
  end
  
  def test_invalid_with_empty_attributes
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?(:login)
    assert user.errors.invalid?(:email)
  end
  
  def test_login_and_email
     user = User.new
     assert !user.valid?
     assert_nil user.email
     assert_nil user.login
     user.email = "quentin@example.com"
     user.login = "jarek1"
     assert_not_nil user.email
     assert_not_nil user.login
     assert !user.valid?
     assert_equal ["has already been taken", "Istnieje użytkownik o takiej nazwie", "has already been taken"], user.errors.on(:login)
     assert_equal ["has already been taken", "Istnieje użytkownik o takim e-mailu", "has already been taken"], user.errors.on(:email)
#     assert_equal ActiveRecord::Errors.default_error_messages[:taken], user.errors.on(:login)
#     assert_equal ActiveRecord::Errors.default_error_messages[:taken], user.errors.on(:email)
     user.email = "kancia@example.com"
     user.login = "kancia" 
     assert !user.valid?, user.errors.full_messages
     user.password = 'nowe'
     user.password_confirmation = 'nowe'
     assert user.valid?, user.errors.full_messages
  end

  def test_no_save
    user = User.new
    assert !user.save
  end
  
  
  def test_save
    user = User.new
    assert !user.save
    user.login = "jakistaki"
    user.email = "jakotaki@example.com"
    assert !user.valid?
    assert !user.save
    #jescze puste pola, ktore sa wymagane w bazie danych
    user.password = 'nowe'
    user.password_confirmation = 'nowe'
#    user.persistence_token = "de68daecd823babbb58edb1c8e14d3333383bb"
#    user.single_access_token = "de68daecd823babbb58edb1ss8e14d7106e83s"
#    user.perishable_token = "de68daecd823babbb58edb1c8e14d710ss83cc"
    assert user.valid?, user.errors.full_messages
    assert user.save, user.errors.full_messages
end

  def test_should_reset_password
    users(:jarek1).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:jarek1).password, User.new(:login=>'jarektest', :password=>'new password', :password_confirmation => 'new password').password
  end
  
  def test_new_user_should_have_role_not_activated
    user = User.new
    assert !user.save
    user.login = "jakistaki"
    user.email = "jakotaki@example.com"
    user.password = 'nowe'
    user.password_confirmation = 'nowe'
#    user.persistence_token = "de68daecd823babbb58edb1c8e14d3333383bb"
#    user.single_access_token = "de68daecd823babbb58edb1ss8e14d7106e83s"
#    user.perishable_token = "de68daecd823babbb58edb1c8e14d710ss83cc"
    assert user.valid?, user.errors.full_messages
    assert_equal 0, user.roles(:all).count
    user.save
    assert_equal 1, user.roles(:all).count
  end
  
  def test_activate
    user = users(:user_not_active)
    assert_raise(RuntimeError) {user.activate! 'zly00000token'}
    assert user.has_role?(:not_activated)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    assert !user.has_role?(:not_activated)
  end
  
  def test_ban_usera
    user = users(:user_not_active)
    assert !user.banned?
    user.ban
    assert user.banned?
    user.unban
    assert !user.banned?
  end
  
  def test_admin_user_active
    user = users(:user_not_active)
    assert_raise(RuntimeError) {user.activate! 'zly00000token'}
    assert user.has_role?(:not_activated)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    assert !user.has_role?(:not_activated)
    assert_equal 0, user.roles(:all).count
    assert !user.is_admin?
    user.no_admin!
    assert !user.is_admin?
    user.admin!
    assert_equal 1, user.roles(:all).count
    assert user.is_admin?
    user.no_admin!
    assert_equal 0, user.roles(:all).count
    assert !user.is_admin?
  end
  
  def test_deliver_password_reset_instructions
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    assert_equal 0, user.roles(:all).count
    assert_nothing_raised {user.deliver_password_reset_instructions!}
  end


  def self.prepare_search_scopes(params = {})
    scope = User.search(:all)
  #TODO !  column :birthday_gte
  #TODO !column :birthday_lte
  scope = scope.login_like(params[:login_like]) if params[:login_like]&& params[:login_like].length > 0
  scope = scope.first_name_like(params[:first_name_like]) if params[:first_name_like] && params[:first_name_like].length > 0
  scope = scope.surname_like(params[:surname_like]) if params[:surname_like] && params[:surname_like].length > 0
  scope = scope.last_login_ip_equals(params[:last_login_ip_equals]) if params[:last_login_ip_equals] && params[:last_login_ip_equals].length > 0

    if(params != nil and params[:roles_attributes] != nil)
      temp = params[:roles_attributes].map {|t| t.to_i}#.reject {|k, v| v.to_i == 0}.to_a.map{|k, v| k}
      if(temp != nil && temp.size > 0)
        scope = scope.by_roles_id(*temp)
      end
    end
    if(params != nil and params[:interests_attributes] != nil)
      temp = params[:interests_attributes].map {|t| t.to_i}#.reject {|k, v| v.to_i == 0}.to_a.map{|k, v| k}
      if(temp != nil && temp.size > 0)
        scope = scope.by_interests_id(*temp)
      end
    end
    return scope
  end

  def test_prepare_search_scopes
    user = users(:user_not_active)
    assert_nothing_raised(RuntimeError) {user.activate! user.single_access_token}
    assert_equal 0, user.roles(:all).count

#    user_search test
    userSearch = UserSearch.new
    userSearch.birthday_gte = nil
    userSearch.birthday_lte = nil
    userSearch.login_like = "user_not_active"
    userSearch.first_name_like = nil
    userSearch.surname_like = nil
    userSearch.last_login_ip_equals = nil
    @roles =:not_activated
    @interests = "sport"
    userSearch.interests_attributes=(@interests)
    userSearch.roles_attributes=(@roles)
    assert_equal [@roles], userSearch.roles
    assert_equal [@interests], userSearch.interests

    scope=User.prepare_search_scopes(userSearch)
    assert_equal 1, scope.count
  end
# def assign_roles
#
#      if(new_record?)
#      #  has_role!(:owner,@user );
#        has_role!(:not_activated);
#      end
#  end
  
  def test_method_per_page
    assert_equal 10, User.per_page
  end

  def test_method_assign_roles
     user = User.new
     user.email = "kancia@example.com"
     user.login = "kancia"
     user.password = 'nowe'
     user.password_confirmation = 'nowe'
     assert user.valid?, user.errors.full_messages

     assert !user.has_role?(:not_activated)
     user.assign_roles
     assert user.has_role?(:not_activated)
  end

#  def test_add_unique_products
#    u = User.new
#    u = Role(:jarek1)
#    u = users(:jarek2)
#    u.add_product rails_book
#    cart.add_product ruby_book
#    assert_equal 2, cart.items.size
#    assert_equal rails_book.price + ruby_book.price, cart.total_price
#  end
#  def test_should_set_remember_token
#    users(:jarek1).remember_me
#    assert_not_nil users(:jarek1).remember_me
#    assert_not_nil users(:jarek1).remember_token_expires_at
#  end
#
#  def test_should_unset_remember_token
#    users(:jarek1).remember_me
#    assert_not_nil users(:jarek1).remember_token
#    users(:jarek1).forget_me
#    assert_nil users(:jarek1).remember_token
#  end
end


