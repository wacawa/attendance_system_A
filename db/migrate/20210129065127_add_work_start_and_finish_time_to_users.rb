class AddWorkStartAndFinishTimeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :work_start_time, :datetime, default: Time.current.change(hour: 9, min: 0, sec: 0)
    add_column :users, :work_finish_time, :datetime, default: Time.current.change(hour: 18, min: 0, sec: 0)
  end
end
