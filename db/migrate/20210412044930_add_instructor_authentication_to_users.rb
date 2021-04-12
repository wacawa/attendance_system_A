class AddInstructorAuthenticationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :instructor_authentication, :string
  end
end
