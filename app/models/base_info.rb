class BaseInfo < ApplicationRecord

  validates :name, presence: true
  validates :type, presence: true, inclusion: { in: %w(出勤 退勤), message: "出勤or退勤のみ可。"  }

end
