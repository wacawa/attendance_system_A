class ChangeInstructorAuthenticationColumn < ActiveRecord::Migration[6.0]
  def change
    change_column :attendances, :instructor_authentication, :string, default: "なし"
  end
end
