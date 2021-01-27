class AddEmployeeAndCardIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :employee_id, :integer
    add_column :users, :card_id, :string
  end
end
