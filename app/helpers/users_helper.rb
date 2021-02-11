module UsersHelper

  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end

  def working_users(user, attendance)
    if Date.current == attendance.worked_on
      Attendance.where.not(started_at: nil).where(finished_at: nil)
    end
  end
  
end
