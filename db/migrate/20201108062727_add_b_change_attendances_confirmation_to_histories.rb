class AddBChangeAttendancesConfirmationToHistories < ActiveRecord::Migration[5.1]
  def change
    add_column :histories, :b_change_attendances_confirmation, :integer
  end
end
