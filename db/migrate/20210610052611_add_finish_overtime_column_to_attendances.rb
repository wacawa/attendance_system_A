class AddFinishOvertimeColumnToAttendances < ActiveRecord::Migration[6.0]
  def change
    add_column :attendances, :finish_overtime, :datetime
  end
end
