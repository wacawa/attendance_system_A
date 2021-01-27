class RemoveBasicWorkTimeFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :basic_work_time
  end
end
