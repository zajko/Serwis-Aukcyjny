class CategoriesController < ApplicationController
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
    @category = Category.new(params[:id])
    name = @category.name
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
    @categories = Category.paginate :page => page, :order => 'name ASC'
  end

end
