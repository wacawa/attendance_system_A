class RemoveInstructorAuthenticationToUsersAndAddToAttendances < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :instructor_authentication
    add_column :attendances, :instructor_authentication, :string
  end
end
