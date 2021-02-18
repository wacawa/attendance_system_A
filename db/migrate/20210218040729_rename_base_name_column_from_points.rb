class RenameBaseNameColumnFromPoints < ActiveRecord::Migration[6.0]
  def change
    rename_column :points, :base_name, :point_name
  end
end
