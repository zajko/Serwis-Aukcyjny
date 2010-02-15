class User < ActiveRecord::Base
  #belongs_to :baseUser, :polymorphic => true
  unloadable
  acts_as_authorization_subject
  acts_as_authorization_object
   acts_as_authentic do |c|
    c.logged_in_timeout = 15.minutes # default is 10.minutes
    #c.merge_validates_length_of_password_confirmation_field_options :message=> {}
    #c.merge_password_field_options :message => "Hasło "
    c.merge_validates_format_of_login_field_options :message => "Nie może zawierać znaków .-_@"
    c.merge_validates_confirmation_of_password_field_options :message => "Potwerdzenie hasła musi zgadzać sie z oryginałem"
    c.merge_validates_length_of_password_field_options :message => "Hasło jest za krótkie."
    c.merge_validates_length_of_login_field_options :message => "Login jest za krótki."
  end
  #has_and_belongs_to_many :roles#_users
 # validate_associated :roles
  #has_many :roles_users
  has_many :bids, :dependent => :destroy
  has_many :articles , :dependent => :destroy
  has_many :charges, :as => :chargeable
  has_many :payments, :as => :payable
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :observed, :class_name => "Auction", :autosave => true#, :readonly => true
  has_many :auctions
  has_and_belongs_to_many :interests
  validates_presence_of :login, :email
  validates_uniqueness_of :login, :message => "Istnieje użytkownik o takiej nazwie"
  validates_uniqueness_of :email, :message => "Istnieje użytkownik o takim e-mailu"
  before_save :assign_roles
  accepts_nested_attributes_for :roles
 # accepts_nested_attributes_for :roles_users

  def self.per_page
    10 #TODO zrób tak, żeby to było w pliku konfiguracyjnym
  end
  named_scope :by_interests_id, lambda{ |*interests|
    {
      :include => :interests, 
      :conditions => ["interests.id IN (?)", interests]#.map(&:name)]
    }
   }
   
   named_scope :by_roles_id, lambda{ |*roles|
    {
      :include => :roles, 
      :conditions => ["roles.id IN (?)", roles]#.map(&:name)]
    }
   }
  def assign_roles

      if(new_record?)
      #  has_role!(:owner,@user );
        has_role!(:not_activated);
      end
  end
  def ban
    has_role!(:banned) if !has_role?(:superuser)
    #TODO dodaj wyslanie e-maila
  end

  def destroy
    if(destroy_check)
      #auctions.destroy_all
      super
    else
      false
    end

  end

  def destroy_check
    if bids and bids.not_cancelled.count > 0
      errors.add("Nie można usunąć użytkownika, który ma aktualne oferty !")
      return false
    end
    #if auctions and auctions.activated.count > 0
    #  errors.add("Nie można usunąć użytkownika, który ma czynne aukcje")
    #  return false
    #end
    return true
  end
  
  def banned?
    has_role?(:banned)
  end
  
  def has_no_role!(role, object=nil)
    if(has_role?(:superuser) and (role.to_s == 'superuser'))
      errors.add("Sorry, uprawnienia superużytkownika nie można odebrać !")
      nil
    else
      super
    end
  end
  
  def has_role!(role, object = nil)
    if(has_role?(:superuser) and (role.to_s == 'banned' || role.to_s == 'not_activated'))
     errors.add("Superużytkownika nie można zbanować ani zdezaktywować !")
     nil
   else
     super
    end
  end

  def unban
    has_no_role!(:banned)
    #TODO dodaj wyslanie e-maila
  end
  
  def admin!
    has_role!(:admin)
  end

    def superuser!
    has_role!(:superuser)
  end


  def no_admin!
    has_no_role!(:admin)
  end
  
  acts_as_authentic do |c|
   #c.my_config_option = my_value
   c.logged_in_timeout = 10.minutes
   #TODO sprawdz czy ten timeout dziala
   #c.openid_required_fields = [:login, :email]
 end
  
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_reset_instructions(self)  
  end  
  
  def activate! token
    if(token == self.single_access_token)
      reset_single_access_token!
      has_no_role!(:not_activated)
      self.save
    else
      raise "Podany token jest niezgodny z tokenem użytkownika"
    end
  end
  
  def is_admin?
    #self.roles.map {|t| t.name.downcase}.include?("admin")
    has_role?(:admin) || has_role?(:superuser)
  end
  
  def self.prepare_search_scopes(params = {})
    scope = User.search(:all)
  #TODO !  column :birthday_gte
  #TODO !column :birthday_lte
  scope = scope.login_like(params[:login_like]) if params[:login_like]&& params[:login_like].length > 0
  scope = scope.first_name_like(params[:first_name_like]) if params[:first_name_like] && params[:first_name_like].length > 0
  scope = scope.surname_like(params[:surname_like]) if params[:surname_like] && params[:surname_like].length > 0
  scope = scope.last_login_ip_equals(params[:last_login_ip_equals]) if params[:last_login_ip_equals] && params[:last_login_ip_equals].length > 0  
  
    if(params != nil and params[:roles_attributes] != nil)
      temp = params[:roles_attributes].map {|t| t.to_i}#.reject {|k, v| v.to_i == 0}.to_a.map{|k, v| k}
      if(temp != nil && temp.size > 0)
        scope = scope.by_roles_id(*temp)
      end
    end
    if(params != nil and params[:interests_attributes] != nil)
      temp = params[:interests_attributes].map {|t| t.to_i}#.reject {|k, v| v.to_i == 0}.to_a.map{|k, v| k}
      if(temp != nil && temp.size > 0)
        scope = scope.by_interests_id(*temp)
      end
    end
    return scope
  end
  
end
