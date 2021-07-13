require 'csv'

CSV.generate do |csv|
  csv_column_names = ["日付", "曜日", "出社時間", "退社時間"]
  csv << csv_column_names
  @attendances.each_with_index do |day, i|
    date = day.worked_on.present? ? l(day.worked_on, format: :short) : nil
    start = day.started_at.present? ? l(day.started_at, format: :time) : nil
    finish = day.finished_at.present? ? l(day.finished_at, format: :time) : nil
    csv_column_values = [date, $days_of_the_week[day.worked_on.wday], start, finish]
    csv << csv_column_values
  end
end