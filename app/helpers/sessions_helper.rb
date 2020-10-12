module SessionsHelper
  def login(user)
    session[:user_id] = user.id
  end

  def logout
    session.delete(:user_id)
    @login_user = nil
  end

  def login_user
    if session[:user_id]
      @login_user ||= User.find_by(id: session[:user_id])
    end
  end

  def logged_in?
    !login_user.nil?
  end
end
