class RenameBasicTimeToBasicWorkTime < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :basic_time, :basic_work_time
  end
end
