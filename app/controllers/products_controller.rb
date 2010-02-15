require 'product_search.rb'
include ProductsHelper
class ProductsController < ApplicationController
  #observer :bid_observer
  #TODO ustal polityke dostepu
  before_filter :load_auction, :only => [:edit, :update, :destroy, :cancell_bid]
  rescue_from Acl9::AccessDenied, :with => :deny_user_access
   access_control do
    #deny :logged_in
    #allow logged_in
    allow all, :to => [:show, :index, :order_by, :advanced_search,:simple_search]
    allow :owner, :of => :auction, :to => [:delete, :edit, :update,:cancell_bid]
    allow :admin, :to => [:delete, :edit, :update, :administer]
    deny :banned, :not_activated, :to=> [:new, :create, :wizard_product_type,:wizard_product_data,:wizard_preview,:wizard_product_create,                         :wizard_summary,
                             :show,:new, :create,:bid, :ask_for_bid_cancellation]
    allow logged_in, :to => [:delete, :wizard_product_type,:wizard_product_data,:wizard_preview,:wizard_product_create,
                             :wizard_summary, :show,:new, :create,:bid, :ask_for_bid_cancellation,:index_admin]
                           #TODO: index_admin ma być dostępny tylko dla superusera!!!
#    allow logged_in, :to => [:edit, :update, :cancell_bid], :if => :editing_mine


    #allow :owner, :of => :auction, :to => [:show, :edit, :update]
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
    @product.build_auction(params[product_type][:auction_attributes])
    @product.auction.attributes = params[product_type][:auction_attributes]
    if params[product_type][:auction_attributes][:category_ids]
      params[product_type][:auction_attributes][:category_ids].each do |c|
        cat = Category.find(c.to_i)
        @product.auction.categories << cat
      end
    end
    if(@product.auction.minimal_price > 0)
      @product.auction.current_price = @product.auction.minimal_price
    else
      @product.auction.current_price = @product.auction.buy_now_price
    end
    @product.auction.user = User.find(current_user.id)
    url = @product.url

    if(!@product.valid?)
        render :action => "wizard_product_data", :product_type => params[product_type],params[product_type] =>params[product_type][:auction_attributes]
    else
      begin
        @product.users_daily=@product.to_parse(url)
        @product.pagerank= @product.page_rank(@product.url)
        if @product.pagerank == nil
          @product.errors.add(:s, "Podany adres jest niewłaściwy lub wskazuje na nieistniejącą stronę")
          render :action => "wizard_product_data", :product_type => params[product_type],params[product_type] =>params[product_type][:auction_attributes]
        end
      rescue
        @product.errors.add(:s, "Podany adres jest niewłaściwy lub wskazuje na nieistniejącą stronę")
        render :action => "wizard_product_data", :product_type => params[product_type],params[product_type] =>params[product_type][:auction_attributes]
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
    #@product.auction = Auction.new
    @cats = Category.find(:all)
    @product.auction.activation_token = ProductsHelper.random_string(20)
   # @product.auction.categories = @cats
  end

  def product_type
    (params[:product_type] || "site_link").underscore
  end

  def activate
    #TODO przenieś logikę z kontrolera do modelu
      @auction = Auction.find(params[:id])
      if @auction == nil
        flash[:notice] = "Aukcja o podanym numerze nie istnieje."
        redirect_to :root
        return
      end
      if !@auction.activated and @auction.end < Time.now
        s ||= @auction.auctionable.url
        begin
          open(@auction.auctionable.url) {
            |f|
            if f.string.contains(@auction.activation_token)
              @auction.activated = true
              @auction.save
              #TODO Dodanie aukcji do kolejki w demonie zamykającym aukcje
              flash[:notice] = "Auckcja aktywowana pomyślnie"
              redirect_to :action => "show", :id => params[:id], :product_type => @auction.auctionable.class
              return
            end
          }
        rescue
          flash[:notice] = "Podany w aukcji url jest niepoprawny lub nie odpowiada"
          redirect_to :action => "show", :id => params[:id], :product_type => @auction.auctionable.class
        end
      else
        redirect_to :index
      end
  end

  def prepare_search
    search = params[:search] || {}
    search.merge!({:product_type => product_type})

    @scope = Kernel.const_get(product_type.classify).prepare_search_scopes(params[:search])#Auction.prepare_search_scopes(search)
    #@scope = Auction.by_categories_name(product_type, *["sport", "turystyka"]).all()#Auction.active.prepare_search_scopes(params[:search])#Kernel.const_get(product_type.classify).prepare_search_scope(params[:search])

  end

  def index
    prepare_search
    @search = ProductSearch.new(params[:search])#Kernel.const_get(product_type.classify).searchObject(params[:search])

    @products = @scope ? @scope.all : []
    #raise "s"
  end
  def wizard_product_create
    
    params[product_type.to_s][:auction_attributes].delete("user_attributes")
    @product = Kernel.const_get(product_type.classify).new(params[product_type.to_s])

    @product.auction.attributes = params[product_type][:auction_attributes]
  #  url = @product.url
  #  @product.users_daily= @product.to_parse(url)
  #  @product.pagerank=@product.page_rank(url)

    if(@product.auction.minimal_price > 0)
      @product.auction.current_price = @product.auction.minimal_price
    else
      @product.auction.current_price = @product.auction.buy_now_price
    end
    @product.auction.user = User.find(current_user.id)
    @product.auction.activated = true
    if(@product.save )
      @product.auction.user.has_role!(:owner, @product.auction)
      redirect_to :action => "wizard_summary", :id => @product.id, :product_type => product_type.to_s#@product.class
      flash[:notice] = "Aukcja została utworzona"
    else
     # render :action => "new"
      flash[:notice] = "Nie udało się utworzyć aukcji"
    end
 end

  def create
    #product_type = params[:product_type] || "site_link"
    @product = Kernel.const_get(product_type.classify).new(params[product_type.to_s])
    @product.build_auction#(params[product_type][:auction_attributes])
    #raise params[product_type][:url]
    @product.auction.attributes = params[product_type][:auction_attributes]

  #  @product.auction = Auction.new(params[product_type][:auction_attributes])

    #@product.build_auction(params[:product][:auction])
    #@product.auction = params[:product][:auction]
   # @product.attributes = params[product_type]

    url = @product.url
    @product.users_daily=@product.to_parse(url)
    @product.pagerank=@product.page_rank(@product.url)
# @product.users_daily =  @product.auction.to_parse(url)
#   @product.pagerank = @product.page_rank(@product.url)

   # raise params[product_type][:url].to_s

   #@product.auction = @product.build_auction(params[product_type][:auction])
   #raise params[:site_link][:auction_attributes]["start"].to_s
   # @t = @product.auction.end

   # @product.auction.end = Time.local(@t.year, @t.mon, @t.day, Time.now.hour)
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
      redirect_to :controller => "personal", :action => "index"
      flash[:notice] = "Aukcja została usunięta"
    else
      render  :controller => "personal", :action => "index"
      flash[:notice] = "Nie można usunąć aukcji"
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
    #TODO obsluz te wyjatki jakos
    @bid.auction.actualize_current_price if @bid.cancell_bid(current_user, params[:decision]);

    redirect_to :action => "show", :id => params[:id], :product_type => params[:product_type]
  end

  def simple_search

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
