class AddDesignatedWorkTimeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :designated_work_start_time, :datetime
    add_column :users, :designated_work_finish_time, :datetime
  end
end
