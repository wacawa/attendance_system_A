class RenameBasesTable < ActiveRecord::Migration[6.0]
  def change
    rename_table :bases, :points
  end
end
