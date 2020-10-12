class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      login @user
      flash[:success] = "\"#{@user.name}さん\"、こんにちは。"
      redirect_to @user
    else
      render :new
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

end