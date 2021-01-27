class AddBasicWorkTimeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :basic_work_time, :datetime, default: Time.current.change(hour: 8, min: 0, sec: 0)
  end
end
