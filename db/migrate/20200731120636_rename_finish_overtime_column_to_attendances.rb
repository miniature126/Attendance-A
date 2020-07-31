class RenameFinishOvertimeColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :finish_overtime, :finish_overwork
  end
end
