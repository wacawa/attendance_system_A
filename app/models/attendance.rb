class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :work_overtime, length: { maximum: 50 }
  validates :overtime_instructor, length: { maximum: 20 }
  validates :before_approval, inclusion: { in: User.where(superior: true).pluck(:superior_name), message: "選択してください。" }, allow_blank: true 
  validates :after_approval, inclusion: { in: User.where(superior: true).pluck(:superior_name), message: "選択してください。" }, allow_blank: true 
  validates :instructor_authentication,
              inclusion: { in: %w(なし 申請中 承認 否認), message: "が無効な値です" }


  validate :finished_at_is_invalid_without_a_started_at
  validate :started_at_than_finished_at_fast_if_invalid
  validate :before_and_after_approval_and_inauthe_are_same_in_one_month

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end

  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は駄目だよ") if started_at > finished_at
    end
  end

  def before_and_after_approval_and_inauthe_are_same_in_one_month
    attendances = Attendance.where("worked_on LIKE ?", "%-01")
    attendances.each do |attendance|
      day = attendance.worked_on.to_date
      user = User.find(attendance.user_id)
      atts = user.attendances.where(worked_on: day..day.end_of_month)
      atts.each do |att|
        unless att.before_approval == attendance.before_approval
          atts.update_all(before_approval: attendance.before_approval)
        end
        unless att.after_approval == attendance.after_approval
          atts.update_all(after_approval: attendance.after_approval)
        end
        unless att.instructor_authentication == attendance.instructor_authentication
          atts.update_all(instructor_authentication: attendance.instructor_authentication)
        end
      end
    end
  end

end
