class CategoriesController < ApplicationController
    rescue_from Acl9::AccessDenied, :with => :deny_user_access
  access_control do
    allow :index do
      allow anonymous, logged_in
      allow :admin
    end
    #deny all, :to => [:new, :delete]
    allow :admin,  :to => [:new, :delete, :create, :index, :show]
    allow :superuser, :to => [:new, :delete, :create, :index]
 #   allow all, :to => [:index] 
  end
  
  def new
    @category = Category.new
  end
  
  def create
    @category = Category.new(params[:category])
    
    if  @category.save
      flash[:notice] = "Kategoria #{@category.name} została utworzona!"
      redirect_to(:action =>'index')
    else
      flash[:notice] = "Błąd przy tworzeniu kategorii #{@category.name}."
      render :action => "new"
    end
  end
  
  def self.per_page
    20
  end
  
  def delete
    @category = Category.find(params[:id])

    if(@category.destroy)

      flash[:notice] = "Kategoria została usunięta"
      redirect_to :action => "index"
    else
      flash[:notice] = "Kategoria NIE została usunięta"
      render :action => :new
    end
  end
  
  def index
    page = params[:page] || 1
    @categories = Category.paginate :page => page,:per_page=>20, :order => 'name ASC'
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
end
