class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :correct_user,
                                  :before_approval, :log, :output_attendances]
  before_action :set_one_month, only: [:show, :before_approval, :log, :output_attendances]
  before_action :logged_in_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :log]
  before_action :admin_or_correct_user, only: [:edit, :update, :log]
  before_action :superior_or_correct_user, only: :show
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]

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
    @after_approval = @user.attendances.find_by(worked_on: @first_day).after_approval
    @before_approval = @user.attendances.find_by(worked_on: @first_day).before_approval
    @in_authe = @user.attendances.find_by(worked_on: @first_day).instructor_authentication
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superiors = User.where(superior: true).where.not(superior_name: @user.superior_name)
    if @user.superior
      @superior_request = Attendance.where(before_approval: @user.superior_name).where("worked_on LIKE ?", "%-01").count
      @atts_edit_request = Attendance.where(before_atts_edit_approval: @user.superior_name).count
      @overtime_request = Attendance.where(before_overtime_approval: @user.superior_name).count
    end
  end

  def before_approval
    @superior = params[:superior]
    if @superior.present?
      @attendances.update_all(before_approval: @superior)
      @attendances.update_all(instructor_authentication: "申請中")
      flash[:success] = "#{@superior}に#{@first_day.month}月度の勤怠承認を申請しました。"
    else
      flash[:danger] = "ユーザーを指定してください。"
    end
    redirect_to @user
  end

  def log
    @default_day = params[:default_day].to_date
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

  def output_attendances
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :department, :employee_id, :card_id, :basic_work_time,
         :password, :password_confirmation, :designated_work_start_time, :designated_work_finish_time)
      
    end

    def basic_info_params
      params.require(:user).permit(:department, :basic_work_time)
    end

    # before_action

      def superior_or_correct_user
        unless login_user?(@user) || login_user.superior?
          flash[:danger] = "権限がねぇ。"
          redirect_to root_url
        end
      end
  
end