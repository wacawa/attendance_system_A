class RenameBaseInfosTable < ActiveRecord::Migration[6.0]
  def change
    rename_table :base_infos, :bases
  end
end
