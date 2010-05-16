require 'products_helper.rb'
require 'net/smtp'
require 'rubysmtp.rb'
class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  before_filter :load_peek_user, :only => [:show]
  rescue_from Acl9::AccessDenied, :with => :deny_user_access
  before_filter :require_no_user

  access_control do
    deny :banned
    deny :not_activated
    allow :superuser
    allow :admin, :to => [:destroy], :if => :cant_destroy_admins
    allow :admin, :to => [:show, :ban, :unban]
    allow :admin
    allow anonymous, :to => [:activate, :new, :create, :show]
    allow :owner, :of => :peeked_user, :to => [:show, :edit, :update, :delete]
  end
  def load_peek_user
    #raise params.to_s
    if(params[:id] == nil)
      if(current_user == nil)
        @peeked_user = nil
        return
      else
        @peeked_user = current_user
        return
      end
    else
      begin
        @peeked_user = User.find(params[:id])
      rescue
        @peeked_user = nil
      end
    end
    
  end
  def cant_destroy_admins
    @u = User.find(params[:id])
    if(@u.id != current_user.id && (@u.has_role?(:admin) || @u.has_role?(:superuser)))
      flash[:notice] = "Użytkownik, którego próbujesz usunąć jest superuserem lub administratorem!"
      return false
    end
    return true
  end
  #TODO zrób to jako parametr w pliku
  
  def new
    @user = User.new
    @interests = Interest.find(:all)
  end
  
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
#    if @user.has_role?(:not_activated)
#      flash[:notice] = "Musisz zaktywować swoje konto"
#      redirect_to :root
#      #TODO Tu ma się pojawić redirect do powiadomienia o tym, że trzeba zaktywować
#      return
#    end
#    flash[:notice] = "Nie masz uprawnień do tej części serisu"
#    redirect_to :root
    #TODO Tu ma się pojawić redirect do powiadomienia o tym, że trzeba zaktywować
    return
  end
  
  def ban
    u_id = params[:passed_id]
    
    @u = User.find(u_id) if u_id
    @u.ban if @u
    
    redirect_to "/users/index"
  end
  
  def unban
    user_id = params[:passed_id]
    @u = User.find(user_id) if user_id 
    @u.unban if @u
    redirect_to "/users/index"
  end
  
  def create
    
    @interests = Interest.find(:all)
    @user = User.new(params[:user])
    @user.activation_token = ProductsHelper.random_string(20)
    if @user.save
      @user.has_role!(:owner, @user)
      begin
        @user.deliver_activation_instructions!(generate_activation_url(@user))
      rescue
        @user.destroy
        flash[:notice] = "Błąd podczas wysyłania listu na adres #{@user.email}"
        redirect_to :root
      end
      redirect_to :controller => "user_sessions", :action => "destroy", :instrukcje => "Twoje konto zostało utworzone. Instrukcja aktywacji została przesłana na adres: #{@user.email}."
      return
    else
      render :action => :new
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to(:action =>'index')
  end
         
  def show
    @id = params[:id] || current_user.id
    @user = User.find(@id)
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "Użytkownik o takim numerze nie istnieje"
    redirect_to :root
  end
 
  def edit
   if(params[:id])
    @user = User.find(params[:id])
   else
    @user = current_user
   end
 end
 
 
  def prepare_search
    search = params[:search] || {}    
    @scope = User.prepare_search_scopes(search)
    #@scope = Auction.by_categories_name(product_type, *["sport", "turystyka"]).all()#Auction.active.prepare_search_scopes(params[:search])#Kernel.const_get(product_type.classify).prepare_search_scope(params[:search])
  end
  
  def index
    page = params[:page] || 1
    prepare_search
    @search = UserSearch.new(params[:search])
    @users = @scope.paginate :page => page, :order => 'login ASC', :per_page=>8
    @roles = Role.appliable#search(:authorizable_type => :null).all
    #User.find(:all, :order => "id")  
  end
  
  def activate
    #postac urla wysyłanego użyszkodnikowi powinna być postaci 
    #www.adres.com/users/activate?[id]=<id_użyszkodnika>&[token]=<single_use_token_użytkownika>
    #UWAGA ! nawiasy kwadratowe wokół id i token są KONIECZNE !
      if(!params[:id])
        flash[:notice] = "Podany url aktywacyjny jest nieprawidłowy" 
        redirect_to :root
      else
        @user = User.find(params[:id])
          
        if(params[:token] == @user.activation_token)
#         @user.activated = true;
          @user.has_no_role!(:not_activated)
          @user.save
          flash[:notice] = "Konto zostało zaktywowane !"
          redirect_to :root
        else
          flash[:notice] = "Podany token aktywacyjny jest nieprawidłowy" 
          redirect_to :root
        end
      end
      
  end
  
  def generate_activation_url user
    if request.env['HTTP_HOST'] == nil # skasować później!
        request.env['HTTP_HOST']=""
    end
    return "http://" + request.env['HTTP_HOST'] + "/users/activate?[id]="+user.id.to_s() +"&[token]=" + user.activation_token
  end
  
  def update
    
    @user = current_user # makes our views "cleaner" and more consistent
    params[:user][:login] = @user.login  # zapewnienie, żeby użyszkodnik nie zmienił sobie loginu
    if @user.update_attributes(params[:user])
      flash[:notice] = "Dane konta zostały zaktualizowane."
      redirect_to account_url
    else
      render :action => :edit
      flash[:notice] = "Błąd aktualizacji danych konta!"
    end
  end
end
