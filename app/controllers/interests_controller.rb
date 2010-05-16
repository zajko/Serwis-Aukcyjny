class InterestsController < ApplicationController
  access_control do
    allow :admin, :superuser
    deny :all
  end
  def new
    @interest = Interest.new
  end

  def create
    @interest = Interest.new(params[:interest])
    if @interest.save
      flash[:notice] = "Utworzono!"
      redirect_to(:action =>'index')
      return
    else
      render :action => :new
    end
  end

  def destroy
    id = params[:id]
    if id == nil
      flash[:notice] = "Musisz podać id!"
      redirect_to(:action =>'index')
      return
    end
    @interest = Interest.find(id)
    if @interest == nil
      flash[:notice] = "Nie istnieje taka kategoria zainteresowania!"
      redirect_to(:action =>'index')
      return
    end
    if @interest.destroy
      flash[:notice] = "Usunięto kategorię zainteresowania!"
      redirect_to(:action =>'index')
      return
    else
      flash[:notice] = "Nie udało się usunąć kategorii zainteresowania!"
      redirect_to(:action =>'index')
      return
    end
  end

  def index
    page = params[:page] || 1
    scope = Interest.scoped({})
    @interests = scope.paginate :page => page, :order => 'name ASC'
  end

end
