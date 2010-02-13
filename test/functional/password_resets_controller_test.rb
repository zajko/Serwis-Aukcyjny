
require File.dirname(__FILE__) + '/../test_helper'


class PasswordResetsControllerTest < ActionController::TestCase

    def test_index
    get :index
    assert_template ''
  end

  def test_new
    get :new
    assert_template ''
  end

  def test_edit
    get :new
    assert_template ''
  end

  def test_create
    post :create, :email=>"154225@student.pwr.wroc.pl"
    assert :success

  end


  protected
    def logowanie_admina
      @controller = UserSessionsController.new
      admin = create_user({:login => 'agnieszka', :email => 'aga@example.com', :password => '1234', :password_confirmation => '1234' })
      admin.activate!(admin.single_access_token)
      admin.admin!
      admin.superuser!
      post :create, :user_session => {:id=>100, :login=>admin.login, :password =>admin.password}
      @controller = UsersController.new
    admin
  end


  protected
    def logowanie_zwyklego_uzytkownika
      @controller = UserSessionsController.new
      user = create_user
      user.activate!(user.single_access_token)
      get :new
      post :create, :user_session => { :login=>user.login, :password =>user.password}
      @controller = UsersController.new
     user
  end


  protected
    def create_user(options = {})

      record = User.new({:id =>'100', :login => 'jarekfuczko', :email => 'jarekfuczko@example.com', :password => '1234', :password_confirmation => '1234' }.merge(options))
      record.save
      record
    end

end
