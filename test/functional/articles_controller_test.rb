
require File.dirname(__FILE__) + '/../test_helper'



class ArticlesControllerTest < ActionController::TestCase
  fixtures :articles
  def test_index
      @controller = UserSessionsController.new
      admin = create_user({:login => 'agnieszka', :email => 'aga@example.com', :password => '1234', :password_confirmation => '1234' })
      admin.activate!(admin.single_access_token)
      admin.admin!
      admin.superuser!
      
      post :create, :user_session => {:id=>100, :login=>admin.login, :password =>admin.password}
      @controller = ArticlesController.new
      get :index
      assert_template 'index'
  end

  def test_show
    test_index
    get :show, :id => Article.first
    assert_template 'show'
  end

  def test_new
    test_index
    get :new
    assert_template 'new'
  end

  def test_create_valid
    test_new
    article = Article.first
    post :create, :article=>{:title=>article.title,:text=>article.text}
    assert_equal "Artykuł został dodany", flash[:notice]
    #Article.any_instance.stubs(:valid?).returns(true)
  end

  def test_create_invalid
    test_new
    article = articles(:one)
    post :create, :article=>{:title=>nil,:text=>nil}
    assert_equal "Błąd: Nie udało się dodać artykułu", flash[:notice]
    #Article.any_instance.stubs(:valid?).returns(false)
  end

  def test_destroy
    test_show
    article = Article.first   
    get :destroy,:id => Article.first.id
    assert_equal "Artykuł został usunięty", flash[:notice]
    
    #assert_template 'destroy'
   end  

  def test_edit_valid
    test_show
    #assert_equal "x", flash[:notice]
    get :edit,:id => Article.first.id
    assert_template 'edit'  
  end

 def test_update_valid
    test_show
    article = articles(:one)
    post :update, :id=>article.id, :article=>{:title=>article.title,:text=>article.text}
    #assert_template 'edit'
    assert_equal "Artykuł został uaktualniony", flash[:notice]
 end


 def test_update_invalid
    test_show
    article = articles(:one)
    post :update, :id=>article.id, :article=>{:title=>"",:text=>""}
    assert_equal "Błąd: Nie udało się uaktualnić artykułu", flash[:notice]
 end


  protected
    def create_user(options = {})
      record = User.new({:id =>'100', :login => 'jarekfuczko', :email => 'jarekfuczko@example.com', :password => '1234', :password_confirmation => '1234' }.merge(options))
      record.save
      record
    end
end