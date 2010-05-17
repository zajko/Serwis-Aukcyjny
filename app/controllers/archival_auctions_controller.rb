class ArchivalAuctionsController < ApplicationController
  rescue_from Acl9::AccessDenied, :with => :deny_user_access

  access_control do
    allow all, :to => [:show]
    allow :superuser, :admin, :to => [:edit, :update, :destroy, :index]
  end  
  
  def prepare_search(params)
    search = params || {}
    #search.merge!({:product_type => product_type})
    
    @scope = ArchivalAuction.prepare_search_scopes(search)#Auction.prepare_search_scopes(search)
  end
  
  def index
    #@search = ProductSearch.new(params[:search])
    page = page || (params ? params[:page] : nil) || 1
    
    @search = ArchivalAuctionSearch.new(params[:search])#Kernel.const_get(product_type.classify).searchObject(params[:search])
    if @search.valid? then
      prepare_search(params[:search])
      @scope = @scope ? @scope.all : []
    else
      prepare_search(nil)
    end
    @archival_auctions = @scope.paginate :page => page,:per_page=>20

  end
  
  def show
    begin
      @archival_auction = ArchivalAuction.find(params[:id])
    rescue
      if params[:id] != nil
        flash[:notice] = "Nie ma aukcji archiwalnej o numerze #{params[:id]}"
      else
        flash[:notice] = "Nie można wyświetlić aukcji archiwalnej bez podania numeru"
      end
      redirect_to :root
    end
  end
  
  def new
    @archival_auctions = ArchivalAuction.new
  end
  
  def create
    @archival_auctions = ArchivalAuction.new(params[:archival_auctions])
    if @archival_auctions.save
      flash[:notice] = "Successfully created archival auctions."
      redirect_to @archival_auctions
    else
      render :action => 'new'
    end
  end
  
  def edit
    @archival_auctions = ArchivalAuctions.find(params[:id])
  end
  
  def update
    @archival_auctions = ArchivalAuctions.find(params[:id])
    if @archival_auctions.update_attributes(params[:archival_auctions])
      flash[:notice] = "Successfully updated archival auctions."
      redirect_to @archival_auctions
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @archival_auctions = ArchivalAuctions.find(params[:id])
    @archival_auctions.destroy
    flash[:notice] = "Successfully destroyed archival auctions."
    redirect_to archival_auctions_url
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
