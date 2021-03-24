class AddSuperiorNameToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :superior_name, :string
  end
end
