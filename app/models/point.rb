class Point < ApplicationRecord

  validates :point_name, presence: true
  validates :attendance_type, inclusion: { in: %w(出勤 退勤), message: "が無効な値です" } , presence: { message: "を選択してください" }

end
