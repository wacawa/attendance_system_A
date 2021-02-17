class PointsController < ApplicationController

  def index
    @bases = Point.all
    @base = Point.new
  end

  def create
    @base = Point.new
  end

  def edit
  end

  def destroy
  end

end
