class CreateBaseInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :base_infos do |t|
      t.string :base_name
      t.string :type

      t.timestamps
    end
  end
end
