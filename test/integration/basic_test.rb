require File.dirname(__FILE__) + '/../test_helper'
#require File.dirname(__FILE__) + '/../_performance_test_helper'
# Profiling results for each test method are written to tmp/performance.
class BasicsTest < ActionController::IntegrationTest

  def test_get_intex
    visits "home/index"
  end

  def test_logowanie
    user = create_user
    visits "home/index"
    click_link "Zaloguj"
    fill_in("login", :with => "jarekfuczko")
    fill_in("password", :with => "1234")
    click_button("Login")
    assert_equal "Zalogowano poprawnie", flash[:notice]
  end

  def test_create_auction
    user = create_user
    visits "home/index"
    click_link "Zaloguj"
    fill_in("login", :with => "jarekfuczko")
    fill_in("password", :with => "1234")
    click_button("Login")
    assert_equal "Zalogowano poprawnie", flash[:notice]
    visits "products/index"

  end



  protected
    def create_user(options = {})
      record = User.new({ :login => 'jarekfuczko', :email => 'jarekfuczko@example.com', :password => '1234', :password_confirmation => '1234' }.merge(options))
      record.activate!(record.single_access_token)
      record.save
      record
  end





#    def test_logout_user_should_get_product_index
#      get 'products/index'
#      assert_response :success
#  end
#
#    def test_logout_user_shouldnt_get_wizard_product_type
#      get 'products/wizard_product_type'
#      assert_equal "Musisz się zalogować", flash[:notice]
#  end
#
#
#    def test_login_user_should_get_wizard_product_type
#      user = create_user
#      user.activate!(user.single_access_token)
#      post_via_redirect '/user_session',:user_session => { :login=>user.login, :password =>user.password}
#      assert_response :success
#      assert_equal "Zalogowano poprawnie", flash[:notice]
#      get 'products/wizard_product_type'
#      #assert_template "products/index"
#      assert_response :success
#  end
#
#    def test_login_then_banned_user_shouldnt_get_wizard_product_type
#      user = create_user
#      user.activate!(user.single_access_token)
#      post_via_redirect '/user_session',:user_session => { :login=>user.login, :password =>user.password}
#      assert_response :success
#      assert_equal "Zalogowano poprawnie", flash[:notice]
#      user.ban
#      get 'products/wizard_product_type'
#      #assert_template "products/index"
#      assert_equal "Twoje konto jest zablokowane", flash[:notice]
#  end
#
#
#
#
#
#
#
#    protected
#    def create_user(options = {})
#      record = User.new({ :login => 'jarekfuczko', :email => 'jarekfuczko@example.com', :password => '1234', :password_confirmation => '1234' }.merge(options))
#      record.save
#      record
#  end

end
