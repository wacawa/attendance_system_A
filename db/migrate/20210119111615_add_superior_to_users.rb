class AddSuperiorToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :superior, :boolean, default: false
  end
end
