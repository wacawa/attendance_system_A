class PointsController < ApplicationController
  before_action :logged_in_user
  before_action :set_point, only: [:destroy, :edit, :update]
  before_action :set_points, only: [:index, :edit]
  before_action :available_admin_user


  def index
    @points = Point.all.order(:id)
    @point = Point.new
  end

  def create
    @point = Point.new(point_params)
    if @point.save
      flash[:success] = "拠点情報を追加しました。"
      redirect_to points_url
    else
      @in = "in"
      @points = Point.all
      flash[:danger] = "拠点情報の追加に失敗しました。"
      render :index
    end
  end

  def destroy
    @point.destroy
    flash[:success] = "拠点情報 \"#{@point.point_name}\" を削除しました。"
    redirect_to points_path
  end

  def edit
  end

  def update
    if @point.update_attributes(point_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to points_path
    else
      flash[:danger] = "拠点情報の更新に失敗しました。"
      @points = Point.all
      render :edit
    end
  end

  def show
  end

  def point_params
    params.require(:point).permit(:id, :point_name, :attendance_type)
  end

  # before_action

  def set_point
    @point = Point.find(params[:id])
  end

  def set_points
    @points = Point.all
  end

end
