class RolesController < ApplicationController

  access_control do
    allow :admin, :superuser
  end

  def new
    @role = Role.new
    @role.authorizable_type = nil
    @role.authorizable_id = nil
    #@users = User.find(:all)
  end
  
  def manage
    @user = User.find(params[:user_id])
    scope = Role.scoped({})
    scope = scope.authorizable_id_null.authorizable_type_null
    @user_roles = @user.roles if @user != nil
    @user_role |= []
    @roles = scope.all

      #find(:all) do |role|
      #!@user.roles.include?(role)
      #role.authorizable_type == nil
      #role.authorizable_id == nil
    #end
  end
  def add_role_to_user
    
    @user = User.find(params[:user_id])
    @role = Role.find(params[:role_id])
    if(@user.roles.include?(@role))
      flash[:notice] = "Użytkownik #{@user.login} już ma rolę #{@role.name}"
    else
      if(@user.has_role!(@role.name))
        flash[:notice] = "Użytkownikowi #{@user.login} przyznano rolę #{@role.name}"
      else
        flash[:notice] = "Użytkownikowi #{@user.login} NIE przyznano roli #{@role.name}. Najprawdopodobniej jest to zabronione"
      end
    end
    redirect_to :action => "manage", :user_id =>params[:user_id]
#    flash[:notice] = "Użytkownikowi #{@user.login} przyznano rolę #{@role.name}"
  end
  
  def remove_role_from_user   
    @user = User.find(params[:user_id])
    @role = Role.find(params[:role_id])
    if(! @user.roles.include?(@role))
      flash[:notice] = "Użytkownik #{@user.login} nie ma roli #{@role.name}"
    else
     #@user.has_no_role!(@role.name)
     @user.roles.delete(@role)
     if(@user.has_role?(@role.name) == false)
      flash[:notice] = "Użytkownikowi #{@user.login} odebrano rolę #{@role.name}"
     else
       flash[:notice] = "Operacja nie powiodła się - użytkownikowi najprawdopodobniej nie można odebrać tej roli"
     end
    end
    redirect_to :action => "manage", :user_id =>params[:user_id]
    
  end
  
  
  def updateRoles
    @user = User.find(params[:user][:id])
    @user.roles.clear
    #raise params[:user][:roles_users_attributes]["0"]["_delete"].to_s 
    params[:user][:roles_users_attributes].map{|k, v| v}.each do |r_u|
      if (!r_u["_delete"] || r_u["_delete"].to_i == 0)
        @role = Role.find(r_u[:role_id])
        @user.roles << @role
        #@roles_users = RolesUser.find(:all) do |r|
         # r.user_id == params[:user][:id]
         # r.role_id == r_u[:role_id]
        #end
        #({:user_id => params[:user][:id], :role_id => r_u[:role_id]})
        #@user.roles_users.delete @roles_users
      else 
        
      end
      
    end
    redirect_to :controller => "users", :action => "index"
    #@user.update(params[:user])
  end

  
  def create    
    @role = Role.new(params[:role])
    begin
      @role.save
      flash[:notice] = "Utworzono rolę!"
      redirect_to(:action =>'index')
    rescue
      flash[:notice] = "Błąd przy tworzeniu roli!"
      redirect_to(:action =>'index')
    end
  end


  def index
    page = params[:page] || 1
    scope = Role.scoped({})
    scope = scope.authorizable_id_null.authorizable_type_null
    @roles = scope.paginate :page => page, :order => 'name ASC'
    #@roles = Role.find(:all) do |role|
    #    role.authorizable_type == nil
    #    role.authorizable_id == nil
    #end
  end
  def delete
    if params[:id] == nil
      flash[:notice] = "Brak numeru roli."
      redirect_to(:action =>'index')
      return
    end
    @role = Role.find(params[:id])
    if(@role.destructible == false)
      flash[:notice] = "Roli #{@role.name} nie da się usunąć."
      redirect_to(:action =>'index')
    else
      name = @role.name
      if @role.destroy
        flash[:notice] = "Rola #{name} usunięta."
        redirect_to(:action =>'index')
      end
    end    
  end

  def edit
  end

  def list
    
  end

end