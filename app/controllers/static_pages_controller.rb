class StaticPagesController < ApplicationController
  before_action :logged_in_user, except: :top
  before_action :available_admin_user, only: [:edit_basic_info, :update_basic_info]
  
  def top
  end

  def edit_basic_info
  end

  def update_basic_info
  end

end
