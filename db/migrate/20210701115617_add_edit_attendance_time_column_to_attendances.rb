class AddEditAttendanceTimeColumnToAttendances < ActiveRecord::Migration[6.0]
  def change
    add_column :attendances, :approval_at, :datetime
  end
end
