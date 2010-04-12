class PasswordResetsController < ApplicationController
    before_filter :load_user_using_perishable_token, :only => [:edit, :update]
    before_filter :require_no_user
  def new
    render
  end

  def edit
    render
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Wysłano instrukcje dotyczące odzyskiwania hasła. Proszę sprawdzić podaną skrzynkę pocztową."
      redirect_to root_url
    else
      render :action => :new
    end
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Hasło zostało zaktualizowane"
      redirect_to root_url
    else
      flash[:notice] = "Wystąpił błąd przy aktualizacji hasła"
      render :action => :edit
    end
  end

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = "Bardzo nam przykro, ale nie możemy zlokalizować podanego konta. Spróbuj skopiować podany w e-mailu link aktywacyjny do przeglądarki, lub rozpocznij proces odzyskiwania hasła od początku"
      redirect_to root_url
    end
  end
end