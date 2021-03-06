class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => :destroy
    access_control do
      allow all
    end
    rescue_from Acl9::AccessDenied, :with => :deny_user_access
  def new
    @user_session = UserSession.new
  end

  def show
    redirect_to :root
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if a = User.find_by_login(params[:user_session][:login])
     if a.has_role?(:not_activated)
       flash[:notice] = "Zaktywuj konto!"
       redirect_back_or_default :root #account_url
       return
     end
     if a.has_role?(:banned)
       flash[:notice] = "Zostałeś zablokowany!"
       redirect_back_or_default :root #account_url
       return
     end
    end
    if @user_session.save
      flash[:notice] = "Zalogowano poprawnie"
      redirect_back_or_default :root #account_url
    else
      render :action => :new
    end
  end
  
  def destroy
    instrukcje = params[:instrukcje]
   # raise instrukcje.to_s
    if(current_user_session)
      current_user_session.destroy
      flash[:notice] = (instrukcje == nil ? "Wylogowano poprawnie" : instrukcje.to_s)
    end
    redirect_to root_url
    #redirect_back_or_default root #new_user_session_url
  end
  protected
  def deny_user_access
    @user =current_user
    if @user == nil
      flash[:notice] = "Musisz się zalogować"
      redirect_to :action=>"new", :controller=>"user_session"
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
