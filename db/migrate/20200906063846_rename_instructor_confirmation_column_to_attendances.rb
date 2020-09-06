class RenameInstructorConfirmationColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :instructor_confirmation, :overwork_confirmation
  end
end
