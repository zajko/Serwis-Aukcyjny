
class HomeController < ApplicationController
  uses_tiny_mce
    rescue_from Acl9::AccessDenied, :with => :deny_user_access
  def index
   # redirect_to :action => "new", :controller => "user_sessions"
    #@dupa = "kupa"
    if !current_user
       @user_session = UserSession.new
    end
    #render(:controller => "articles", :action => "index")
    
    @a = ArticlesController.new
    @a.index params[:page]
    @articles = @a.articles 
    #render :template => 'articles/index'
    #@scope.paginate :page => page, :order => 'login ASC'  
  end

    protected
  def deny_user_access
    @user =current_user
    if @user == nil
      flash[:notice] = "Musisz się zalogować"
      redirect_to :root
      return
    end
  end

  
end
