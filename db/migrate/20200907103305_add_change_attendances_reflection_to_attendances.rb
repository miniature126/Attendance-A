class AddChangeAttendancesReflectionToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_attendances_reflection, :boolean
  end
end
