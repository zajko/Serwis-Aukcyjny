require 'product_search.rb'
require 'products_helper.rb'
include ProductsHelper
class ProductsController < ApplicationController
  #observer :bid_observer
  #TODO ustal polityke dostepu
  before_filter :load_auction, :only => [:unobserve,:observe,:edit, :update, :destroy, :cancell_bid]
  rescue_from Acl9::AccessDenied, :with => :deny_user_access
   access_control do
    allow all, :to => [:activate, :show, :index, :order_by, :advanced_search,:simple_search]
    allow :owner, :of => :auction, :to => [:delete, :edit, :update,:cancell_bid]
    deny :owner, :of => :auction, :to => [:observe, :unobserve]
    allow :admin, :to => [:delete, :edit, :update, :administer, :cancell_bid, :index_admin]
    allow :superuser, :to => [:delete, :edit, :update, :administer, :cancell_bid, :index_admin]
    deny :banned, :not_activated, :to=> [:new, :create, :wizard_product_type,:wizard_product_data,:wizard_preview,:wizard_product_create,                         :wizard_summary,
                             :show,:new, :create,:bid, :ask_for_bid_cancellation]
    allow logged_in, :to => [:observe, :unobserve, :delete, :wizard_product_type,:wizard_product_data,:wizard_preview,:wizard_product_create,
                             :wizard_summary, :show,:new, :create,:bid, :ask_for_bid_cancellation,:index_admin]
                           #TODO: index_admin ma być dostępny tylko dla superusera!!!
  end

  def wizard_product_type
  end

  def wizard_product_data
    
    if params[:product_type]!=nil
      @product = Kernel.const_get(product_type.classify).new
      @product.auction = @product.build_auction
      @cats = Category.find(:all)
    # @product.auction.activation_token = ProductsHelper.random_string(20)
    else
      flash[:notice] = "Błąd: Nie wybrano typu produktu!"
    end
     
  end
  
  def wizard_preview

    if params[:minimal_price]
      params[product_type][:auction_attributes][:minimal_price] = params[:minimal_price]
      params.delete(:minimal_price)
    end
    if params[:minimal_bidding_difference]
      params[product_type][:auction_attributes][:minimal_bidding_difference] = params[:minimal_bidding_difference]
      params.delete(:minimal_bidding_difference)
    end
    if params[:buy_now_price]
      params[product_type][:auction_attributes][:buy_now_price] = params[:buy_now_price]
      params.delete(:buy_now_price)
    end

    @product = Kernel.const_get(product_type.classify).new(params[product_type.to_s])
    if(@product.auction.minimal_price > 0)
      @product.auction.current_price = @product.auction.minimal_price
    else
      @product.auction.current_price = @product.auction.buy_now_price
    end
    @product.auction.user = User.find(current_user.id)
    url = @product.url
    if url != nil
      @product.url = "http://"+@product.url if (url =~ /^(http|https):\/\//) == nil
    end
    if(!@product.valid?)
      
        render :action => "wizard_product_data"#, :product_type => params[product_type],params[product_type] =>params[product_type][:auction_attributes]
    else
      begin
        @product.users_daily=@product.to_parse(url)
        @product.pagerank= @product.page_rank(@product.url)
        if @product.pagerank == nil
         @product.pagerank = 0
        end
      rescue
        @product.pagerank = 0
      end
      params[product_type][:pagerank] = @product.pagerank
      params[product_type][:users_daily] = @product.users_daily
    end
  end
  
  def wizard_summary

    product_type = params[:product_type] || "site_link"
    @product = Kernel.const_get(product_type.classify).find(params[:id])
  end


  def new
    @product = Kernel.const_get(product_type.classify).new
    @product.auction = @product.build_auction
    @cats = Category.find(:all)
    #@product.auction.activation_token = ProductsHelper.random_string(20)
  end

  def product_type
    (params[:product_type] || "site_link").underscore
  end

  def activate
      @auction = Auction.find(params[:id])
      
      if @auction == nil
        
        flash[:notice] = "Aukcja o podanym numerze nie istnieje."
        redirect_to :root
        return
      else
        if @auction.activate then
          flash[:notice] = "Auckcja została zaktywowna"
          redirect_to :action => "show", :id => @auction.auctionable.id, :product_type => @auction.auctionable.class
        else
          flash[:notice] = "Nie zaktywowano aukcji!"
          redirect_to :action => "show", :id => @auction.auctionable.id, :product_type => @auction.auctionable.class
        end
      end
  end

  def prepare_search(additional_parameters = {})
    search = params[:search] || {}
    search.merge!(additional_parameters) #, :categories_attributes => search[:search_categories]
    @scope = Kernel.const_get(product_type.classify).prepare_search_scopes(search)#Auction.prepare_search_scopes(search)
  end
 
  def index

    if !params[:search] and params[:search_categories]
      params[:search] = {}
      params[:search][:categories_attributes] = params[:search_categories]
    end
    if params[:search_categories] == nil and params[:search]
      params[:search_categories] = params[:search][:categories_attributes]
    end
    prepare_search({:product_type => product_type, :auction_not_expired => true, :auction_opened => "byleco", :auction_activated => true})
    @search_categories=params[:search_categories] || params[:categories_attributes]
    page = params[:page] || 1
    @search_type=params[:search_type]
    @search = ProductSearch.new(params[:search])
    params[:search_categories] = @search.categories_attributes
    #@search_categories.each do |e|
    #  @search.categories_attributes=e
    #end if @search_categories
    if @scope != nil and @scope.count > 0
      @products = (@scope.paginate :page => page, :per_page=>20)
    else
      @products = []
    end
    
  end
  
  def index_admin
   # raise "A"
    if !params[:search] and params[:search_categories]
      params[:search] = {}
      params[:search][:categories_attributes] = params[:search_categories]
    end
    if params[:search_categories] == nil and params[:search]
      params[:search_categories] = params[:search][:categories_attributes]
    end
    if params[:product_type]
      params[:search].merge!({:by_auctionable_type => params[:product_type].classify})
    end
    search = params[:search] || {}
    @scope = Auction.prepare_search_scopes(search)
    @search_categories=params[:search_categories] || params[:search][:categories_attributes]
    @search = ProductSearch.new(params[:search])
    @search_type=params[:search_type]
    page = params[:page] || 1
   # params[:search_categories] = @search.categories_attributes
    @auctions = @scope.all.paginate :page => page, :per_page=>20
    
  end

  def wizard_product_create
    params[product_type.to_s][:auction_attributes].delete("user_attributes")
    @product = Kernel.const_get(product_type.classify).new(params[product_type.to_s])
    #@product.auction.attributes = params[product_type][:auction_attributes]  

    if(@product.auction.minimal_price > 0)
      @product.auction.current_price = @product.auction.minimal_price
    else
      @product.auction.current_price = @product.auction.buy_now_price
    end
    @product.auction.user = User.find(current_user.id)
    @product.auction.activated = @product.class.to_s == "MailingService"
    @product.auction.activation_token = ProductsHelper.random_string(20)
    
    if(@product.save )
      @product.auction.user.has_role!(:owner, @product.auction)
      
      @product.auction.deliver_auction_activation_instructions!
      redirect_to :action => "wizard_summary", :id => @product.id, :product_type => product_type.to_s#@product.class
      flash[:notice] = "Aukcja została utworzona."
      flash[:notice] = flash[:notice] + " Na Twoją skrzynkę pocztową wysłano instrukcje do aktywacji aukcji." if ! @product.auction.activated
    else
     # render :action => "new"
      flash[:notice] = "Nie udało się utworzyć aukcji"
    end
 end

  def create
    raise "METODA PRZESTARZAŁA"
    #product_type = params[:product_type] || "site_link"
    @product = Kernel.const_get(product_type.classify).new(params[product_type.to_s])
    @product.build_auction#(params[product_type][:auction_attributes])
    #raise params[product_type][:url]
    @product.auction.attributes = params[product_type][:auction_attributes]


    url = @product.url
    @product.users_daily=@product.to_parse(url)
    @product.pagerank=@product.page_rank(@product.url)
    @product.auction.user = User.find(current_user.id)
   if( @product.auction.save and  @product.save )
    redirect_to :action => "wizard_summary", :id => @product.id, :product_type => @product.class
   else
    render :action =>  "wizard_summary"
   end
  end

  def delete
    product_type = params[:product_type]
    @product = Kernel.const_get(product_type.classify).find(params[:id])

    if(@product.destroy)
      redirect_to :controller => "personal", :action => "created_auctions"
      flash[:notice] = "Aukcja została usunięta"
    else
      redirect_to :controller => "personal", :action => "created_auctions"
      if @product.auction.bids.not_cancelled.count > 0
        flash[:notice] = "Aukcja ma ważne (nieanulowane) oferty - nie można jej usunąć"
      else
        flash[:notice] = "Nie można usunąć aukcji."
      end
      
    end
  end

  def negate_order order
    if(order.include?("ASC"))
      "DESC"
    else
      "ASC"
    end
  end

  def order_by
    column_name = params[:column_name]
    if params[:search] == nil
      params.merge({:search => nil})
      params[:search] = {:order_by => nil}
    end
        if params[:search][:order_by]
          params[:search][:order_by] = params[:column_name] + " " + negate_order(params[:search][:order_by])
        else
          params[:search][:order_by] = params[:column_name] + " " + "ASC"
        end
    redirect_to :action=> "index", :search => params[:search], :product_type => params[:product_type]
  end

  def edit
    product_type = params[:product_type].tableize || "site_link"

    @product = Kernel.const_get(product_type.classify).find(params[:id])
  end

  def update
    product_type = params[:product_type] || "site_link"
    @product = Kernel.const_get(product_type.classify).find(params[product_type.to_s][:id], :readonly => false)
    #@product.auction.categories
    if (params[:category_ids])
      params[:category_ids].each do |category_id|
        @category = Category.find(category_id)
        @product.auction.categories << @category  if ! @product.auction.categories.include? @category
      end
    end
    if( @product.update_attributes(params[product_type]))
      @product.auction.update_attributes(params[product_type][:auction_attributes])
      @product.auction.categories =  params[product_type][:auction_attributes][:category_ids].map{|x| Category.find(x.to_i)} if params[product_type][:auction_attributes][:category_ids] and params[product_type][:auction_attributes][:category_ids].count > 0
      redirect_to :action => "show", :id => @product.id, :product_type => @product.class
    else
      render :action => 'edit', :id => @product.id, :product_type => @product.class
    end
  end

  def show
    product_type = params[:product_type] || "site_link"
    @bid = Bid.new
    @product = Kernel.const_get(product_type.classify).find(params[:id])
  end

  def bid
    Bid.transaction do
     Auction.transaction do
       @product = Kernel.const_get(product_type.classify).find(params[:product_id])
       params[:bid][:offered_price] =params[:bid][:offered_price].gsub(/,/ , '.' ) if params[:bid][:offered_price]
       @bid = Bid.new(params[:bid])
       @bid.bid_created_time = Time.now
       if @bid.save
          if @product.auction.buy_now_price > 0
             flash[:notice] = "Twoja oferta została przyjęta - produkt jest już Twoją własnością."
          else
            flash[:notice] = "Twoja oferta została przyjęta."
          end
         redirect_to :action => "show", :id => @product.id, :product_type => @product.class.to_s
       else
         #@auction = Auction.find(params[:bid][:auction_id])
         render :action => "show", :id => @product.id, :product_type => @product.class.to_s, :product_id => @product.id
       end
     end
    end
  end

  def ask_for_bid_cancellation

     bid_id = params[:bid_id]
     @bid = Bid.find(bid_id)
     raise "No auction with id = #{bid_id}" if @bid == nil
     raise "Must be logged in" if current_user == nil
     #TODO obsluz te wyjatki jakos
     @bid.ask_for_cancell(current_user)
    redirect_to :action => "show", :id => params[:id], :product_type => params[:product_type]
  end

  def cancell_bid
    bid_id = params[:bid_id]
    @bid = Bid.find(bid_id)
    raise "No auction with id = #{bid_id}" if @bid == nil
    raise "Must be logged in" if current_user == nil
    #TODO obsłużyć to z redirectem jak należy
    @bid.auction.actualize_current_price if @bid.cancell_bid(params[:decision]);

    redirect_to :action => "show", :id => params[:id], :product_type => params[:product_type]
  end

  def simple_search


  end
  def unobserve
    if(params[:id] == nil)
      raise "Brak numeru produktu"
      #TODO obsłużyć to z redirectem jak należy
    end
    @product = Kernel.const_get(product_type.classify).find(params[:id])
    @auction = @product.auction
    @user = current_user
    if ! @user
      raise "Brak aktualnego użytkownika"
      #TODO obsłużyć to z redirectem jak należy
    end
    @user.observed.delete(@auction)
    redirect_to :action => "show", :id => @product.id, :product_type => @product.class.to_s
  end

  def observe
    if(params[:id] == nil)
      raise "Brak numeru produktu"
      #TODO obsłużyć to z redirectem jak należy
    end
    @product = Kernel.const_get(product_type.classify).find(params[:id])
    @auction = @product.auction
    @user = current_user
    if !@user
      raise "Brak aktualnego użytkownika"
      #TODO obsłużyć to z redirectem jak należy
    end
    @user.observed << @auction
    redirect_to :action => "show", :id => @product.id, :product_type => @product.class.to_s
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

  def load_auction
    if(params[:id] == nil)
      @auction = nil
      return nil
    end
    @auction = Auction.find(:first, :conditions => ['auctionable_type = ? and auctionable_id = ?', product_type.classify, params[:id] ])#Article.find(params[:id])
  end
end
