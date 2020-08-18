class ChangeDataInstructorConfirmationToAttendances < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :instructor_confirmation, :integer
  end
end
