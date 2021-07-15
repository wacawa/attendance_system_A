class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :superior_request, :update_superior_request,
                                  :attendances_edit_request, :update_attendances_edit_request,
                                  :overtime_request, :update_overtime_request]
  before_action :set_user_for_user_id, only: [:update,
                                              :overtime_request_to_superior, :update_overtime_request_to_superior]
  before_action :set_users, only: [:superior_request, :attendances_edit_request, :overtime_request]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month]
  before_action :not_available_admin_user

  
  
  UPDATE_ERROR_MSG = "勤怠登録をやり直してください。"
  
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
        flash[:info] = "お疲れさまでした。"
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
    msg = []
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        worked_on = attendance.worked_on
        if item["started_at(4i)"].present? && item["finished_at(4i)"].present?
          if item[app].present?
            s_min = item["started_at(5i)"].present? ? item["started_at(5i)"] : "00"
            f_min = item["finished_at(5i)"].present? ? item["finished_at(5i)"] : "00"
            start_time = "#{item["started_at(4i)"]}:#{s_min}"
            finish_time = "#{item["finished_at(4i)"]}:#{f_min}"
            default_start = attendance.started_at.present? ? l(attendance.started_at, format: :time) : ""
            default_finish = attendance.finished_at.present? ? l(attendance.finished_at, format: :time) : ""
            if default_start != start_time || default_finish != finish_time
              start_time = "#{worked_on}-#{start_time}".to_time
              finish_day = params[:user]["overnight#{id}"] == "1" ? "#{worked_on.next_day}" : "#{worked_on}"
              finish_time = "#{finish_day}-#{finish_time}".to_time
              if start_time <= finish_time
                item = [["new_started_at", start_time], ["new_finished_at", finish_time],
                        ["note", item[:note]], [app, item[app]], [a, item[a]]]
                item << ["old_started_at", attendance.started_at] if attendance.old_started_at.nil?
                item << ["old_finished_at", attendance.finished_at]
                item = item.to_h
                attendance.update_attributes!(item)
                msg = ["success", "変更を送信しました。"] if msg.blank?
              else
                msg = ["danger", "申請に失敗した日付があります。"]
              end
            end
          end
        else
          unless item["started_at(4i)"].blank? && item["finished_at(4i)"].blank?
            msg = ["danger", "申請に失敗した日付があります。"] unless item[app].blank?
          end
        end
      end
      flash[msg[0]] = msg[1] if msg.present?
      redirect_to user_url(date: params[:date])
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "入力データが無効な値のため、更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end 
  end
  
  def superior_request
    @request_attendances = Attendance.where(before_approval: @user.superior_name).where("cast(worked_on as text) LIKE ?", "%-01").order(:worked_on)
  end

  def update_superior_request
    msg = []
    ActiveRecord::Base.transaction do
      request_params.each do |id, item|
        if params["checkbox#{id}"] == "1" && item[:instructor_authentication] != "申請中"
          attendance = Attendance.find(id)
          user = User.find(attendance.user_id)
          attendances = user.attendances.where(worked_on: attendance.worked_on..attendance.worked_on.end_of_month)
          if item[:instructor_authentication] == "なし"
            item[:before_approval] = nil
            item[:after_approval] = nil
            attendances.update_all(item.to_h)
          else
            attendances.update_all(item.to_h)
          end
          msg = ["success", "変更を送信しました。"] if msg.blank?
        elsif params["checkbox#{id}"] == "1" && item[:instructor_authentication] == "申請中"
          msg = ["danger", "変更の送信に失敗した申請があります。"]
        end
      end
      flash[msg[0]] = msg[1] if msg.present?
      redirect_to @user
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "変更の送信に失敗しました。"
      redirect_to @user
    end
  end

  def attendances_edit_request
    @requests = Attendance.where(before_atts_edit_approval: @user.superior_name).order(:worked_on)
  end

  def update_attendances_edit_request
    a = "atts_edit_instructor_authentication"
    msg = []
    ActiveRecord::Base.transaction do
      request_params.each do |id, item|
        if params["checkbox#{id}"] == "1"
          if item[a] != "申請中"
            attendance = Attendance.find(id)
            user = User.find(attendance.user_id)
            case item[a]
            when "なし" then
              item = [[a, item[a]], ["note", nil], ["new_started_at", nil], ["new_finished_at", nil], 
                      ["before_atts_edit_approval", nil], ["after_atts_edit_approval", nil]].to_h
              attendance.update_attributes!(item)
            when "否認" then
              item = [[a, item[a]], ["note", nil], ["new_started_at", nil], ["new_finished_at", nil], 
                      ["before_atts_edit_approval", nil], ["after_atts_edit_approval", "上長2"]].to_h
              attendance.update_attributes!(item)
            when "承認" then
              attendance.update_attributes!(item)
            end
            msg = ["success", "変更を送信しました。"] if msg.blank?
          else
            msg = ["danger", "変更の送信に失敗した申請があります。"]
          end
        end
      end
      flash[msg[0]] = msg[1] if msg.present?
      redirect_to @user
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "変更の送信に失敗しました。"
      redirect_to @user
    end
  end

  def overtime_request_to_superior
    @attendance = Attendance.find(params[:id])
    @superiors = User.where(superior: true).where.not(superior_name: @user.superior_name).pluck(:superior_name)
  end

  def update_overtime_request_to_superior
    if params[:attendance][:before_overtime_approval].present?
      if params[:attendance]["finish_overtime(4i)"].present?
        params[:attendance]["finish_overtime(5i)"] ||= "00"        
        overtime = "#{params[:attendance]["finish_overtime(4i)"]}:#{params[:attendance]["finish_overtime(5i)"]}"
        attendance = Attendance.find(params[:id])
        day = params["overnight#{attendance.id}"] == "0" ? attendance.worked_on : attendance.worked_on.next_day
        overtime = "#{day}-#{overtime}".to_time
        if attendance.update_attributes(overtime_request_params) && attendance.update_attributes(finish_overtime: overtime)
          msg = ["success", "変更を送信しました。"]
        else
          msg = ["danger", "変更の送信に失敗しました。"]
        end
      else
        msg = ["danger", "終了予定時間未選択のため送信をキャンセルしました。"]
      end
    else
      msg = ["danger", "指示者確認欄未選択のため送信をキャンセルしました。"] if params[:attendance]["finish_overtime(4i)"].present?
    end
    msg ||= []
    flash[msg[0]] = msg[1] if msg.present?
    redirect_to @user
  end

  def overtime_request
    @request_overtime = Attendance.where(before_overtime_approval: @user.superior_name).order(:worked_on)
  end

  def update_overtime_request
    msg = []
    ActiveRecord::Base.transaction do
      request_params.each do |id, item|
        logger.debug(Attendance.find(id).inspect)
        if params["checkbox#{id}"] == "1"
          if item["overtime_instructor_authentication"] != "申請中"
            attendance = Attendance.find(id)
            item["finish_overtime"] = nil if item["overtime_instructor_authentication"] == "なし"
            item["after_overtime_approval"] = nil if item["overtime_instructor_authentication"] == "なし"
            attendance.update_attributes!(item)
            msg = ["success", "変更を送信しました。"] if msg.blank?
          else
            msg = ["danger", "変更の送信に失敗した申請があります。"]
          end
        else
          if item["overtime_instructor_authentication"] != "申請中"
            msg = ["danger", "変更の送信に失敗した申請があります。"]
          end
        end
      end
      flash[msg[0]] = msg[1] if msg.present?
      redirect_to @user
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "変更の送信に失敗しました。"
      redirect_to @user
    end
  end
  
  private

  def set_user_for_user_id
    @user = User.find(params[:user_id])
  end

  def set_users
    @users = User.all
  end
  
  def attendances_params
    params.require(:user).permit(
      attendances: [:started_at, :finished_at, :note, :before_atts_edit_approval, :atts_edit_instructor_authentication]
    )[:attendances]
  end

  def request_params
    params.permit(requests: {})[:requests]
  end

  def overtime_request_params
    params.require(:attendance).permit([:task, :before_overtime_approval, :overtime_instructor_authentication])
  end
  
  # beforeフィルター

end
