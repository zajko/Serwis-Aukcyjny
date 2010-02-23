class ArticlesController < ApplicationController
  before_filter :load_article, :only => [:edit, :update, :destroy]
  access_control do
    allow logged_in, :to => [:index, :show, :articles]
    allow all, :to => [:show]
    allow :superuser, :admin, :to => [:new, :create]
    allow :superuser, :to => [:edit, :update, :destroy]
    allow :owner, :of => :article, :to => [:edit, :update, :destroy]
  end  
  
  def index (page = nil)
    page = page || (params ? params[:page] : nil) || 1
    @articles = Article.paginate :page => page, :order => 'created_at DESC'
  end

  def articles
    @articles
  end

  def show
    flash[:notice] = "Artykul szczegoly"
    @article = Article.find(params[:id])
  end
  
  def new
    @article = Article.new
  end
  
  def create
    @article = Article.new(params[:article])
    @article.user = current_user
    current_user.has_role!(:owner, @article)
    if @article.save
      flash[:notice] = "Artykuł został dodany"
      #redirect_to @article
      redirect_to :action => "index"
    else
      flash[:notice] = "Błąd: Nie udało się dodać artykułu"
      render :action => 'new'
    end
  end
  
  def edit
    @article = Article.find(params[:id])
  end
  
  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      flash[:notice] = "Artykuł został uaktualniony"
      redirect_to @article
    else
      render :action => 'edit'
      flash[:notice] = "Błąd: Nie udało się uaktualnić artykułu"
    end
  end
  
  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    flash[:notice] = "Artykuł został usunięty"
    redirect_to articles_url
  end

 
  
  protected
  def load_article
    if(params[:id] == nil)
      @article = nil
      return nil
    end
    @article = Article.find(params[:id])
  end
end



