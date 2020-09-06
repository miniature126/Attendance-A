class AddChangeAttendancesConfirmationToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_attendances_confirmation, :integer
  end
end
