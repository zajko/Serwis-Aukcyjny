
require File.dirname(__FILE__) + '/../test_helper'

class UserSessionsControllerTest < ActionController::TestCase
   fixtures :users

 def test_new_sesion
   # sign in?
    get :new
    assert_response :success 
    assert_template "user_sessions/new"

end


def test_login_user_not_activated
  user = create_user
  get :new
  assert_response :success
  post :create, :user_session => { :login=>user.login, :password =>user.password}
#  assert_redirected_to :controller => :home , :action => :index
  assert_template ""
  assert_not_nil assigns(:user_session)
  assert_equal "Zaktywuj konto!", flash[:notice]
end

def test_login_user_activated
  user = create_user
#  aktywuj uzytkownika
  user.activate!(user.single_access_token)
  
  get :new
  assert_response :success
  post :create, :user_session => { :login=>user.login, :password =>user.password}
#  assert_redirected_to :controller => :home , :action => :index
  assert_template ""
  assert_not_nil assigns(:user_session)
  assert_equal "Zalogowano poprawnie", flash[:notice]
end

def test_login_user_ban
  user = create_user
#  aktywuj uzytkownika
  user.activate!(user.single_access_token)
  user.ban
  
  get :new
  assert_response :success
  post :create, :user_session => { :login=>user.login, :password =>user.password}
#  assert_redirected_to :controller => :home , :action => :index
  assert_template ""
  assert_not_nil assigns(:user_session)
  assert_equal "Zostałeś zablokowany!", flash[:notice]
end

def test_login_user_admin
  user = create_user
#  aktywuj uzytkownika
  user.activate!(user.single_access_token)
  user.admin!
  
  get :new
  assert_response :success
  post :create, :user_session => { :login=>user.login, :password =>user.password}
#  assert_redirected_to :controller => :home , :action => :index
  assert_template ""
  assert_not_nil assigns(:user_session)
  assert_equal "Zalogowano poprawnie", flash[:notice]
end

def test_login_user_superuser
  user = create_user
#  aktywuj uzytkownika
  user.activate!(user.single_access_token)
  user.has_role!(:superuser)
  
  get :new
  assert_response :success
  post :create, :user_session => { :login=>user.login, :password =>user.password}
#  assert_redirected_to :controller => :home , :action => :index
  assert_template ""
  assert_not_nil assigns(:user_session)
end

def test_login_user_not_valid_login
  get :new
  assert_response :success
  post :create, :user_session => { :login=>"zlylogin", :password =>"halo"}
#  assert_redirected_to :controller => :home , :action => :index
  assert_response :success
  assert_not_nil assigns(:user_session)
  assert_template "user_sessions/new"
end
  
def test_login_user_superuser
  user = create_user
#  aktywuj uzytkownika
  user.activate!(user.single_access_token)
  user.has_role!(:superuser)
  
  get :new
  assert_response :success
  post :create, :user_session => { :login=>user.login, :password =>"zlehaslo"}
#  assert_redirected_to :controller => :home , :action => :index
  assert_template "user_sessions/new"
  assert_not_nil assigns(:user_session)
end

def test_logout_error
  get :destroy
  assert_equal "Wylogowano poprawnie", flash[:notice]
end

def test_logout_success
#  logowanie
  user = create_user
#  aktywuj uzytkownika
  user.activate!(user.single_access_token)
  
  get :new
  assert_response :success
  post :create, :user_session => { :login=>user.login, :password =>user.password}
#  assert_redirected_to :controller => :home , :action => :index
  assert_template ""
  assert_not_nil assigns(:user_session)
  assert_equal "Zalogowano poprawnie", flash[:notice]
  assert_template ""
  
#  wylogowywanie
  get :destroy, :controller =>:user_sessions
  assert_equal "Wylogowano poprawnie", flash[:notice]
  assert_template ""
  assert_equal "Wylogowano poprawnie", flash[:notice]
#  post :destroy, :user_session => { :login=>user.login, :password =>user.password}
end


  protected
    def create_user(options = {})
      record = User.new({ :login => 'jarekfuczko', :email => 'jarekfuczko@example.com', :password => '1234', :password_confirmation => '1234' }.merge(options))
      record.save
      record
  end
  
end