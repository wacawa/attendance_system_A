class AddOldStartedAndFinishedAtColumnToAttendances < ActiveRecord::Migration[6.0]
  def change
    add_column :attendances, :old_started_at, :datetime
    add_column :attendances, :old_finished_at, :datetime
  end
end
