class Point < ApplicationRecord

  validates :point_name, presence: true
  validates :attendance_type, presence: true, inclusion: { in: %w(出勤 退勤), message: "は出勤or退勤のみ可。"  }

end
