
require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
     fixtures :users

  def test_go_to_index
    logowanie_admina
    get :index
    assert_template 'index'
  end

 def test_update_user_valid
      logowanie_admina
        post :update,
                  :authenticity_token=>"pwGufI2qiPMbprrDgxmdg0uyOb61FUfhPwb5+pP4qFg=",
                  :user=>{:password_confirmation=>"111111",
                          :login=>"xxsdx",
                          :surname=>" ",
                          :password=>"111111",
                          :email=>"154253@student.pwr.wroc.pl",
                          :first_name=>" "}
                        assert_equal "Account updated!", flash[:notice]
    assert :success
  end

  def test_update_user_invalid
      logowanie_admina
        post :update,
                  :authenticity_token=>"pwGufI2qiPMbprrDgxmdg0uyOb61FUfhPwb5+pP4qFg=",
                  :user=>{:password_confirmation=>"111",
                          :login=>"xxsdx",
                          :surname=>" ",
                          :password=>"111111",
                          :email=>"154253@student.pwr.wroc.pl",
                          :first_name=>" "}
                        assert_equal "Update error!", flash[:notice]
    assert :success
  end


  def test_register_invalid
            post :create,
                  :authenticity_token=>"pwGufI2qiPMbprrDgxmdg0uyOb61FUfhPwb5+pP4qFg=",
                  :user=>{:password_confirmation=>"111",
                          :login=>"xxsdx",
                          :surname=>" ",
                          :password=>"111111",
                          :email=>"154253@student.pwr.wroc.pl",
                          :first_name=>" "}
            assert :succes
  end

  def test_register_valid
            post :create,
                  :authenticity_token=>"pwGufI2qiPMbprrDgxmdg0uyOb61FUfhPwb5+pP4qFg=",
                  :user=>{:password_confirmation=>"111111",
                          :login=>"xxsdx",
                          :surname=>" ",
                          :password=>"111111",
                          :email=>"154257@student.pwr.wroc.pl",
                          :first_name=>" "
                          }
            assert :succes
            
  end

  def test_activate_invalid
    get :activate
    assert :succes
  end

  def test_activate_valid
    get :activate, :id=>2, :token => "http:///users/activate?[id]=1357057437&[token]=730JdD3JtnBZi3BGSWmv"
    assert :succes
  end

  def test_new_user
    get :index
    get :new
    assert :success
  end

  def test_ban
    logowanie_admina
    post :ban, :passed_id=>2
    assert :success
    assert_template ''
  end

  def test_ubban
    logowanie_admina
    post :unban, :passed_id=>2
    assert :success
    assert_template ''
  end

    def test_create
    logowanie_admina
    post :create
    assert :success
    assert_template ''
  end


    def test_edit_another_user
    logowanie_admina
    post :edit, :id=>2
    assert :success
    assert_template ''                    
  end


    def test_edit_myself
    logowanie_admina
    post :edit
    assert :success
    assert_template ''
  end

    def test_show
    logowanie_admina
    post :show, :id=>2
    assert :success
    assert_template ''
  end

    def test_destroy
    logowanie_admina
    post :destroy, :id=>2
    assert :success
    assert_template ''
  end

 
  def test_load_peek_user
   post :load_peek_user, :id=>2
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


