class PasswordResetsController < ApplicationController
    before_filter :load_user_perishable_toke, :only => [:edit, :update]
    before_filter :require_no_user 
  def new
    render
  end

#  def create
#    @user = User.find_by_email(params[:email])
#
#      if @user
#        @user.deliver_password_reset_instructions!
#        flash[:notice] = "Instrukcja zmiany hasła została wysłana na Twój adres. Sprawdź swoją skrzynkę."
#        redirect_to :root
#      else
#        flash[:notice] = "Nie istnieje użytkownik identyfikujący się danym z e-mailem."
#        redirect_to :root
#      end
#  end
#
#  def index
#    if(flash[:notice])
#      flash[:notice] = flash[:notice]
#    end
#    redirect_to :root
#  end
#
#  def edit
#    render
#  end
#
#  def update
#
#    @user.password = params[:user][:password]
#    @user.password_confirmation = params[:user][:password_confirmation]
#    if @user.save
#      flash[:notice] = "Password successfully updated"
#      redirect_to account_url
#    else
#      render :action => :edit
#    end
#  end
#
# private
#  def load_user_using_perishable_token
#    @user = User.find_using_perishable_token(params[:id])
#    unless @user
#    flash[:notice] = "We're sorry, but we could not locate your account . If you are having issues try copying and pasting the URL " +
# "from your email into your browser or restarting the " +
# "reset password process."
#    redirect_to root_url
#    end
#  end

end