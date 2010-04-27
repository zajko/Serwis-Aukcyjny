class ArchivalAuctionsController < ApplicationController
  access_control do
    allow all, :to => [:show, :index]
    
    allow :superuser, :admin, :to => [:edit, :update, :destroy]
  end  
  
  def prepare_search
    search = params[:search] || {}
    #search.merge!({:product_type => product_type})
    
    @scope = ArchivalAuction.prepare_search_scopes(search)#Auction.prepare_search_scopes(search)
  end
  
  def index       
    prepare_search
    @search = ProductSearch.new(params[:search])#Kernel.const_get(product_type.classify).searchObject(params[:search])
    
    @products = @scope ? @scope.all : []
    @archival_auctions = ArchivalAuction.all
  end
  
  def show
    @archival_auctions = ArchivalAuction.find(params[:id])
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
end
