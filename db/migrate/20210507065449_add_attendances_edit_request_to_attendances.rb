class AddAttendancesEditRequestToAttendances < ActiveRecord::Migration[6.0]
  def change
    add_column :attendances, :before_atts_edit_approval, :string
    add_column :attendances, :after_atts_edit_approval, :string
    add_column :attendances, :atts_edit_instructor_authentication, :string, default: "なし"
  end
end
