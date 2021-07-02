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
        if !item[app].present?
          error << true if item["started_at(4i)"].present? && item["finished_at(4i)"].present?
        elsif item["started_at(4i)"].present? && item["finished_at(4i)"].present?
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
                  ["note", item[:note]], [app, item[app]], [a, item[a]]]
          item << ["old_started_at", attendance.started_at] if attendance.old_started_at.nil?
          item << ["old_finished_at", attendance.finished_at] if attendance.old_finished_at.nil?
          item = item.to_h
          if start_time < finish_time
            attendance.update_attributes!(item)
          else
            error << true
          end
#        elsif item["started_at(4i)"].present? && item["finished_at(4i)"].present? && !item[app].present?
#          error << true
        end
      end
    end
    flash[:danger] = "申請に失敗した日付があります。" if error.present?
    flash[:success] = "勤怠変更を申請しました。" unless error.present?
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "入力データが無効な値だったから、更新をキャンセルしたよ"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end 
  
  def superior_request
    @request_attendances = Attendance.where(before_approval: @user.superior_name).where("worked_on LIKE ?", "%-01").order(:worked_on)
  end

  def update_superior_request
    ActiveRecord::Base.transaction do
      request_params.each do |id, item|
        if params["checkbox#{id}"] == "1" && item[:instructor_authentication] != "申請中"
          attendance = Attendance.find(id)
          user = User.find(attendance.user_id)
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
          flash[:danger] = "「指示者確認㊞」を変更し、チェックを入れて送信してください。"
        end
      end
      redirect_to @user
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "変更の送信に失敗しました。"
      redirect_to @user
    end
  end

  def attendances_edit_request
    @requests = Attendance.where(before_atts_edit_approval: @user.superior_name)
  end

  def update_attendances_edit_request
    a = "atts_edit_instructor_authentication"
    errors = []
    ActiveRecord::Base.transaction do
      request_params.each do |id, item|
        if params["checkbox#{id}"] == "0"
          errors << true
        elsif item[a] != "申請中"
          attendance = Attendance.find(id)
          user = User.find(attendance.user_id)
          case item[a]
          when "なし", "否認" then
            item = [[a, item[a]], ["note", nil], ["new_started_at", nil], ["new_finished_at", nil], 
                    ["before_atts_edit_approval", nil], ["after_atts_edit_approval", "上長2"]].to_h
            attendance.update_attributes!(item)
          when "承認" then
            attendance.update_attributes!(item)
          end
        else
          errors << true
        end
      end
      flash[:success] = "変更を送信しました。" unless errors.present?
      flash[:danger] = "送信に失敗した申請があります。" if errors.present?
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
      overtime = "#{params[:attendance]["finish_overtime(4i)"]}:#{params[:attendance]["finish_overtime(5i)"]}".to_time 
      if overtime.present? 
        attendance = Attendance.find(params[:id])
        day = params["overnight#{attendance.id}"] == "0" ? attendance.worked_on : attendance.worked_on.next_day
        overtime = "#{day}-#{overtime}".to_time
        if attendance.update_attributes(overtime_request_params) && attendance.update_attributes(finish_overtime: overtime)
          msg = ["success", "変更を送信しました。"]
        else
          msg = ["danger", "変更の送信に失敗しました。"]
        end
      else
        msg = ["danger", "終了予定時間未入力のため送信をキャンセルしました。"]
      end
    else
      msg = ["danger", "指示者確認欄未選択のため送信をキャンセルしました。"]
    end
    flash[msg[0]] = msg[1] if msg.present?
    redirect_to @user
  end

  def overtime_request
    @request_overtime = Attendance.where(before_overtime_approval: @user.superior_name)
  end

  def update_overtime_request
    errors = []
    ActiveRecord::Base.transaction do
      request_params.each do |id, item|
        logger.debug(Attendance.find(id).inspect)
        if params["checkbox#{id}"] == "0"
          errors << true
        elsif item["overtime_instructor_authentication"] != "申請中"
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
        end
#        logger.debug(Attendance.find(id).inspect)
      end
      flash[:success] = "変更を送信しました。" unless errors.present?
      flash[:danger] = "送信に失敗した申請があります。" if errors.present?
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
