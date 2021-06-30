require 'csv'

CSV.generate do |csv|
  csv_column_names = %w(日付 曜日 出社時間 退社時間)
  csv << csv_column_names
  @attendances.each do |day|
    if day.started_at && day.finished_at
      csv_column_values = [day.worked_on, $days_of_the_week[day.worked_on.wday], day.started_at, day.finished_at]
      csv << csv_column_values
    end
  end
end