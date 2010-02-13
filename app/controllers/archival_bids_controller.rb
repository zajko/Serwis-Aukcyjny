class ArchivalBidsController < ApplicationController
  access_control do
    allow all, :to => [:show, :index]
    
    allow :superuser, :admin, :to => [:edit, :update, :destroy]
  end  
  def index
    @archival_bids = ArchivalBid.all
  end
  
  def show
    @archival_bid = ArchivalBid.find(params[:id])
  end
  
  def new
    @archival_bid = ArchivalBid.new
  end
  
  def create
    @archival_bid = ArchivalBid.new(params[:archival_bid])
    if @archival_bid.save
      flash[:notice] = "Successfully created archival bid."
      redirect_to @archival_bid
    else
      render :action => 'new'
    end
  end
  
  def edit
    @archival_bid = ArchivalBid.find(params[:id])
  end
  
  def update
    @archival_bid = ArchivalBid.find(params[:id])
    if @archival_bid.update_attributes(params[:archival_bid])
      flash[:notice] = "Successfully updated archival bid."
      redirect_to @archival_bid
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @archival_bid = ArchivalBid.find(params[:id])
    @archival_bid.destroy
    flash[:notice] = "Successfully destroyed archival bid."
    redirect_to archival_bids_url
  end
end
