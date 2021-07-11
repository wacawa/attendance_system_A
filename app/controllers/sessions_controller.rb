class SessionsController < ApplicationController
  before_action :not_login, only: [:new, :create]
  
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.admin
      login user
      redirect_to root_url
    elsif user && user.authenticate(params[:session][:password])
      login user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or(user)
    else
      flash.now[:danger] = '認証に失敗しました。'
      render :new
    end
  end

  def destroy
    logout if logged_in?
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end

  def not_login
    if logged_in?
      flash[:danger] = "ログアウトしてください。"
      redirect_to root_url
    end
  end
end
