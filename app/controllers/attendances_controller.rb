class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :attendance_log, :log, :before_approval, :superior_request]
  before_action :set_user_for_user_id, only: [:update]
  before_action :logged_in_user, only: [:update, :edit_one_month, :attendance_log, :log]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month, :log]
  before_action :set_one_month, only: [:edit_one_month, :log, :before_approval]
  
  UPDATE_ERROR_MSG = "勤怠登録をやり直してくだ。"
  
  def update
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "こんにちは。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end      
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "入力データが無効な値だったから、更新をキャンセルしたよ"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end 
  
  def log
    @default_day = params[:default_day].to_date
  end

  def before_approval
    @superior = params[:superior]
    if @attendances.update_all(before_approval: @superior)
      flash[:success] = "#{@superior}に#{@first_day.month}月度の勤怠承認を申請しました。"
      redirect_to @user
    end
  end

  def superior_request
    @users = User.all
    @request_attendances = Attendance.where("worked_on LIKE ?", "%-01").where(before_superior: @user.superior_name)
  end

  def attendances_edit_request
  end

  def overtime_request
  end
  
  private

  def set_user_for_user_id
    @user = User.find(params[:user_id])
  end
  
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :work_overtime, :overtime_instructor])[:attendances]
  end
  
  # beforeフィルター
  
  
end
