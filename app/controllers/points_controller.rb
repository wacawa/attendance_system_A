class PointsController < ApplicationController
  before_action :set_point, only: [:destroy]
  before_action :set_points, only: [:index]

  def index
    @points = Point.all
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
      render :index
    end
  end

  def destroy
    @point.destroy
    flash[:success] = "拠点情報 \"#{@point.point_name}\" を削除しました。"
    redirect_to points_path
  end

  def edit
    @points = Point.all
    @point = Point.find(params[:id])
  end

  def update
    @point = Point.find(params[:id])
    if @point.update_attributes(point_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to points_path
    else
      flash[:danger] = "拠点情報の更新に失敗しました。"
      render :edit
    end
  end

  def show
  end

  def point_params
    params.require(:point).permit(:point_name, :attendance_type)
  end

  # before_action

  def set_point
    @point = Point.find(params[:id])
  end

  def set_points
    @points = Point.all
  end

end
