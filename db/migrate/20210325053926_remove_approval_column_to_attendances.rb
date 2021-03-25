class RemoveApprovalColumnToAttendances < ActiveRecord::Migration[6.0]
  def change
    remove_column :attendances, :approval
    add_column :attendances, :before_approval, :string
    add_column :attendances, :after_approval, :string
  end
end
