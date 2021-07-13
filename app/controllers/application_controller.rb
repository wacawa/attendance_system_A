class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  $days_of_the_week = %w{日 月 火 水 木 金 土}

  # before_action

  def set_user
    @user = User.find(params[:id])
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end

  def correct_user
    unless login_user?(@user)
      flash[:danger] = "権限がありません。"
      redirect_to(root_url)
    end
  end

  def admin_or_correct_user
    if !login_user?(@user) && !login_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end

  def available_admin_user
    unless login_user.admin?
      flash[:danger] = "アクセス権限がありません。"
      redirect_to root_url
    end
  end

  def not_available_admin_user
    if login_user.admin?
      flash[:danger] = "アクセス権限がありません。"
      redirect_to root_url 
    end
  end

  def set_one_month
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        one_month.each {|day| @user.attendances.create!(worked_on: day)}
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)  
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "ページ情報の取得に失敗しました。再アクセスしてください。"
    redirect_to root_url
  end

end
