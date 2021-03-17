module AttendancesHelper
  
  def working_or_not(attendance)
    if Date.current == attendance.worked_on
      return attendance.started_at.present? ? attendance.finished_at.nil? : nil
    end
  end
  
  def attendance_state(attendance, x)
    if Date.current == attendance.worked_on
      return "出勤" if working_or_not(attendance) == nil && x == 0
      return "退勤" if working_or_not(attendance) && x == 1
    end
  end
  
  def working_times(start, finish)
    format("%.2f", ((finish - start) / 3600.0))
  end

end
