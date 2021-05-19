class AddNewStartedAtAndNewFinishedAtColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :attendances, :new_started_at, :datetime
    add_column :attendances, :new_finished_at, :datetime
  end
end
