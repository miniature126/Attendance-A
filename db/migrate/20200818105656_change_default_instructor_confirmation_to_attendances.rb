class ChangeDefaultInstructorConfirmationToAttendances < ActiveRecord::Migration[5.1]
  def up
    change_column :attendances, :instructor_confirmation, :integer, default: nil
  end
  
  def down
    change_column :attendances, :instructor_confirmation, :integer, default: 2
  end
end
