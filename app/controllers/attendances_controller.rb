class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :superior_request, :update_superior_request,
                                  :attendances_edit_request, :update_attendances_edit_request]
  before_action :set_user_for_user_id, only: [:update]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month]
  
  
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
    @superiors = User.where(superior: true).where.not(superior_name: @user.superior_name).pluck(:superior_name)
  end
  
  def update_one_month
    app = "before_atts_edit_approval"
    a = "atts_edit_instructor_authentication"
    error = []
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[app].present? && item["started_at(4i)"].present? && item["finished_at(4i)"].present?
          s_min = item["started_at(5i)"].present? ? item["started_at(5i)"] : "00"
          f_min = item["finished_at(5i)"].present? ? item["finished_at(5i)"] : "00"
          worked_on = attendance.worked_on
          start_time = "#{item["started_at(4i)"]}:#{s_min}"
          finish_time = "#{item["finished_at(4i)"]}:#{f_min}"
          if attendance.finished_at.present? 
            next if l(attendance.started_at, format: :time) == start_time && l(attendance.finished_at, format: :time) == finish_time
          end
          start_time = "#{worked_on}-#{item["started_at(4i)"]}:#{s_min}".to_time
          finish_day = params[:user]["overnight#{id}"] == "1" ? "#{worked_on.next_day}" : "#{worked_on}"
          finish_time = "#{finish_day}-#{item["finished_at(4i)"]}:#{f_min}".to_time
          item = [["new_started_at", start_time], ["new_finished_at", finish_time],
                  ["note", item[:note]], [app, item[app]], [a, item[a]]].to_h
          debugger
          attendance.update_attributes!(item)
        elsif item["started_at(4i)"].present? && item["finished_at(4i)"].present? && !item[app].present? 
          error << true if attendance.new_started_at.present? || attendance.new_finished_at.present?
        end
      end
    end
    if msg = error.count > 0
      flash[:danger] = "更新されていない日付があります。"
    else
      flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    end
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    debugger
    flash[:danger] = "入力データが無効な値だったから、更新をキャンセルしたよ"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end 
  
  def superior_request
    @users = User.all
    @request_attendances = Attendance.where(before_approval: @user.superior_name).where("worked_on LIKE ?", "%-01").order(:worked_on)
  end

  def update_superior_request
    ActiveRecord::Base.transaction do
      request_params.each do |id, item|
        attendance = Attendance.find(id)
        user = User.find(attendance.user_id)
        if params["checkbox#{id}"] == "1" && item[:instructor_authentication] != "申請中"
          attendances = user.attendances.where(worked_on: attendance.worked_on..attendance.worked_on.end_of_month)
          attendances.update_all(item.to_h)
          wanted_data_list = attendances.pluck(:before_approval, :after_approval, :instructor_authentication)
          if item[:instructor_authentication] == "なし"
            list = wanted_data_list.transpose[2].uniq[0]
            attendances.update_all(instructor_authentication: list)
            flash[:success] = "変更を送信しました。"
          else
            wanted_data_update(attendances, wanted_data_list)
            flash[:success] = "変更を送信しました。"
          end
        else
          flash[:danger] = "「指示者確認」を変更し、チェックを入れて送信してください。"
        end
      end
      redirect_to @user
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "変更の送信に失敗しました。"
      redirect_to @user
    end
  end

  def attendances_edit_request
    @users = User.all
    @requests = Attendance.where(before_atts_edit_approval: @user.superior_name)
  end

  def update_attendances_edit_request
    request_params.each do |id, item|
      attendance = Attendance.find(id)
      user = User.find(attendance.user_id)
      a = "atts_edit_instructor_authentication"
      if params["checkbox#{id}"] == "1" && item[a] != "申請中"
        #attendance.update_attributes!(atts_edit_instructor_authentication: item[a]) if item[a] == "なし"
        #attendance.update_attributes!(item) if item[a] == "承認" || item[a] == "否認"
        flash[:success] = "変更を送信しました。"
        redirect_to @user
      else
        flash[:danger] = "「指示者確認㊞」欄を変更し、チェックを入れて送信してください。"
        redirect_to @user
      end
    end
  end

  def overtime_request
  end
  
  private

  def set_user_for_user_id
    @user = User.find(params[:user_id])
  end
  
  def attendances_params
    params.require(:user).permit(
      attendances: [:started_at, :finished_at, :note, :before_atts_edit_approval, :atts_edit_instructor_authentication]
    )[:attendances]
  end

  def request_params
    params.permit(requests: {})[:requests]
  end
  
  # beforeフィルター

end
