
require File.dirname(__FILE__) + '/../test_helper'

 
class ProductsControllerTest < ActionController::TestCase
fixtures :site_links
  
  def test_index_valid
    get :index
    assert_response :success
  end

  def test_without_logon_shouldnt_get_wizard_product_type
      get :wizard_product_type
      assert_equal "Musisz się zalogować", flash[:notice]
  end

    def test_wizard_product_type_notactivateduser_invalid
      logowanie_zwyklego_uzytkownika
      get :new
      get :wizart_product_type
      assert_equal "Nie masz uprawnień do tej części serwisu", flash[:notice]
  end

  def test_wizard_product_type_banneduser_invalid
      @controller = UserSessionsController.new
      user = create_user
      user.activate!(user.single_access_token)
      post :create, :user_session => { :login=>user.login, :password =>user.password}
      user.ban
      @controller = ProductsController.new
      get :wizart_product_type
      assert_equal "Twoje konto jest zablokowane", flash[:notice]
  end

    def test_wizard_product_type_valid
      logowanie_zwyklego_uzytkownika
      get :wizart_product_type
      assert :success
    end

     def test_wizard_product_data_invalid
      logowanie_zwyklego_uzytkownika
      get :wizart_product_type
      assert :success
      get :wizard_product_data
      assert :success
      assert_equal "Błąd: Nie wybrano typu produktu!", flash[:notice]
    end


    def test_wizard_product_data_valid
      logowanie_zwyklego_uzytkownika
      get :wizart_product_type
      assert :success
      
      get :wizard_product_data, :product_type=>"site_link"
      assert :success
      assert_template "products/wizard_product_data"
    end


    def test_show_valid
      logowanie_admina
      get :show, :product_type=>"site_link", :id=>1
      assert :success
      assert_template "products/show"
    end

    def test_edit_valid
      logowanie_admina
      get :edit, :product_type=>"site_link", :id=>1
      assert :success
      assert_template "products/edit"
    end

    def test_delete_valid
      logowanie_admina
      get :delete, :product_type=>"site_link", :id=>1
      assert :success
      
    end

    def test_disactivated_user_shouldnt_get_wizard_product_type
     #zrobic
    end




#    def test_delete
#      logowanie_admina
#
#      get :detete, :product_type=>"site_link"
#      assert :success
#
#    end



    def test_go_to_wizard_preview
      test_wizard_product_data_valid
      post :wizard_preview, :product_type=>"site_link",
                            :commit=>"Dalej",
                            :authenticity_token=>"Vo5WUjcNDGFxMamyUZE9Ljp7KYF0TmIOuIwfrbBZ/x0=",
                            :site_link=>
                            {
                                      :url=>"http://www.onet.pl",
                                      :auction_attributes=>
                                      {
                                                  :start=>"2010-1-10",
                                                  :activation_token=>"",
                                                  :auction_end=>"2010-1-20",
                                                  :category_ids=>"1"
                                       }
                            },
                            :buy_now_price=>"0.0",
                            :minimal_bidding_difference=>"5.0",
                            :ch_buyNow=>"on"
    assert_equal "Test", flash[:notice]
      assert_template "products/wizard_product_data"

    end


    def test_go_to_wizard_summary
      admin=logowanie_admina
     post :wizard_summery, :product_type=>"site_link",:id=>"1"
     #assert_template "products/wizard_product_data"
     
    
    end







################################################################################################################
  
  def test
    a = Auction.by_auctions_id [1,2,3]
    b = a.all 
  end
  
  protected
    def create_user(options = {})
  
      record = User.new({:id =>'100', :login => 'jarekfuczko', :email => 'jarekfuczko@example.com', :password => '1234', :password_confirmation => '1234' }.merge(options))
      record.save
      record
    end

  protected
    def logowanie_admina
      @controller = UserSessionsController.new
      admin = create_user({:login => 'agnieszka', :email => 'aga@example.com', :password => '1234', :password_confirmation => '1234' })
      admin.activate!(admin.single_access_token)
      admin.admin!
      admin.superuser!
      post :create, :user_session => {:id=>100, :login=>admin.login, :password =>admin.password}
      @controller = ProductsController.new
    admin
  end


  protected
    def logowanie_zwyklego_uzytkownika
      @controller = UserSessionsController.new
      user = create_user
      user.activate!(user.single_access_token)
      get :new
      post :create, :user_session => { :login=>user.login, :password =>user.password}
      @controller = ProductsController.new
     user
  end

  
end