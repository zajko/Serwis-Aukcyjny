class InterestsController < ApplicationController
      rescue_from Acl9::AccessDenied, :with => :deny_user_access
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
