class RenameTypeColumnToBaseinfo < ActiveRecord::Migration[6.0]
  def change
    rename_column :base_infos, :type, :attendance_type
  end
end
