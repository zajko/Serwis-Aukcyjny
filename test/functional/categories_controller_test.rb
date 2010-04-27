
require File.dirname(__FILE__) + '/../test_helper'


class CategoriesControllerTest < ActionController::TestCase
  fixtures :categories
  def test_index
      @controller = UserSessionsController.new
      admin = create_user({:login => 'agnieszka', :email => 'aga@example.com', :password => '1234', :password_confirmation => '1234' })
      admin.activate!(admin.single_access_token)
      admin.admin!
      admin.superuser!

      post :create, :user_session => {:id=>100, :login=>admin.login, :password =>admin.password}
      @controller = CategoriesController.new
      get :index
      assert_template 'index'
  end

  def test_new
    test_index
    get :new, :category=> {:name=>"nazwa"}
    assert_template 'new'
  end

  def test_create_valid
    test_index
    get :create, :category=> {:name=>"nazwa"}
#    assert_template 'new'
    assert_equal "Kategoria nazwa została utworzona!", flash[:notice]
  end

  def test_create_invalid
    test_index
    get :create, :category=> nil
    assert_equal "Błąd przy tworzeniu kategorii .", flash[:notice]
  end

  def test_delete_valid
    test_index
    cat = categories(:one)
    get :delete, :name=>cat.name
    assert_equal "Kategoria została usunięta", flash[:notice]
    #assert_template 'index'
  end

  def test_delete_invalid
    test_index
    get :delete, :category=>{:name=>nil}
    assert_equal "Kategoria NIE została usunięta", flash[:notice]
    
  end


  protected
    def create_user(options = {})
      record = User.new({:id =>'100', :login => 'jarekfuczko', :email => 'jarekfuczko@example.com', :password => '1234', :password_confirmation => '1234' }.merge(options))
      record.save
      record
    end
end
