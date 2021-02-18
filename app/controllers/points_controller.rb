class PointsController < ApplicationController

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
      render :index
    end
  end

  def edit
  end

  def destroy
    @point = Point.find(params[:id])
    @point.destroy
    flash[:success] = "拠点情報 \"#{@point.point_name}\" を削除しました。"
    redirect_to points_url
  end

  def update
    @point = Point.find(params[:id])
  end

  def point_params
    params.require(:point).permit(:point_name, :attendance_type)
  end

end
