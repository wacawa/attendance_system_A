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

  def wanted_data_update(attendances, list)
    if list.uniq.count == 1
      attendances.update_all(before_approval: list[0][0]) 
      attendances.update_all(after_approval: list[0][1]) 
      attendances.update_all(instructor_authentication: list[0][2]) 
    end
  end

end
