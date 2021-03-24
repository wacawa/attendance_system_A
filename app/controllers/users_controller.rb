class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :correct_user]
  before_action :logged_in_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_or_correct_user, only: [:edit, :update]
  before_action :correct_user, only: :show
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show

  def index_working_users
    @users = User.paginate(page: params[:page])
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def import
    User.import(params[:file])
    redirect_to users_url
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @approval = @attendances.find_by(worked_on: @first_day).approval? ? "済" : "未"
    @superiors = User.where(superior: true)
    @superior = User.find_by(superior_name: params[:superior])
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

  def edit
  end

  def update
    location = (request.referer == edit_user_url ? @user : users_url)
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to location
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "ユーザー \"#{@user.name}\" を削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新に失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :department, :employee_id, :card_id, :basic_work_time,
         :password, :password_confirmation, :designated_work_start_time, :designated_work_finish_time)
      
    end

    def basic_info_params
      params.require(:user).permit(:department, :basic_work_time)
    end


end