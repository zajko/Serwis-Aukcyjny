# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'validates_uri_existance'
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user
  @@static_user = nil
  
  def ApplicationController.get_static_user
    @@static_user
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return (@@static_user = @current_user) if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
    @@static_user = @current_user
  end
  
  def require_user
      unless self.current_user
        store_location
        flash[:notice] = "Musisz się zalogować"
        redirect_to new_user_session_url
        return false
      end
    end
 
    def require_no_user
      if current_user
        store_location
        flash[:notice] = "Musisz być wylogowany"
        redirect_to account_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
