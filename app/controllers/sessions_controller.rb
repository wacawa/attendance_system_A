class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      login user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      debugger
      redirect_to user
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
end
