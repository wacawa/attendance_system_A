class AddColumnsToAttendances < ActiveRecord::Migration[6.0]
  def change
    rename_column :attendances, :work_overtime, :task
    rename_column :attendances, :overtime_instructor, :before_overtime_approval
    add_column :attendances, :after_overtime_approval, :string
    add_column :attendances, :overtime_instructor_authentication, :string, default: "なし"
  end
end
