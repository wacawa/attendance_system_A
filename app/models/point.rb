class Point < ApplicationRecord

  validates :point_name, presence: true
  validates :attendance_type, presence: { message: "を選択してください。" }, inclusion: { in: %w(出勤 退勤) } 

  after_validation :remove_error_msg

  def remove_error_msg
  end

end
