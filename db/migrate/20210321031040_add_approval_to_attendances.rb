class AddApprovalToAttendances < ActiveRecord::Migration[6.0]
  def change
    add_column :attendances, :approval, :boolean, default: false
  end
end
