class ArticlesController < ApplicationController
  before_filter :load_article, :only => [:edit, :update, :destroy]
  access_control do
    allow logged_in, :to => [:index, :show, :articles]
    allow all, :to => [:show,:index]
    allow :superuser, :admin
    #allow :superuser, :to => [:edit, :update, :destroy]
    allow :owner, :of => :article, :to => [:edit, :update, :destroy]
  end

  def index_admin
    
    page = params ? params[:page] : nil || 1
    @articles = Article.all.paginate :page => page, :order => 'created_at DESC',:per_page=>20
  end
  
  def index (page = nil)
    page = page || (params ? params[:page] : nil) || 1
    @articles = Article.paginate :page => page, :order => 'created_at DESC',:per_page=>20
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
    if params[:id] == nil
      
      flash[:notice] = "Musisz podać numer artykułu !"
      redirect_to :action => "index"
      return
    end
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      flash[:notice] = "Artykuł został uaktualniony"
      redirect_to :action => "show", :id => @article.id
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
 def deny_user_access
    @user =current_user
    if @user == nil
      flash[:notice] = "Musisz się zalogować"
      redirect_to :root
      return
    end

    if @user.has_role?(:banned)
      flash[:notice] = "Twoje konto jest zablokowane"
      redirect_to :root
      return
    end
    if @user.has_role?(:not_activated)
      flash[:notice] = "Musisz zaktywować swoje konto"
      redirect_to :root
      #TODO Tu ma się pojawić redirect do powiadomienia o tym, że trzeba zaktywować
      return
    end
    flash[:notice] = flash[:notice] ? flash[:notice] : "Nie masz uprawnień do tej części serwisu"
    redirect_to :root
    #TODO Tu ma się pojawić redirect do powiadomienia o tym, że trzeba zaktywować
    return
  end  
  def process_file_uploads(task)
    
      i = 0
      while params[:article][:attachments_attributes][i.to_s] != "" && !params[:article][:attachments_attributes][i.to_s].nil?
          t = task.attachments.build(:data => params[:article][:attachments_attributes][i.to_s][:data])
          i += 1
          
      end
  end

  def load_article
    if(params[:id] == nil)
      @article = nil
      return nil
    end
    @article = Article.find(params[:id])
  end

end