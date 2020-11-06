class CreateAttendances < ActiveRecord::Migration[6.0]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.string :note
      t.string :work_overtime
      t.string :overtime_instructor
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
