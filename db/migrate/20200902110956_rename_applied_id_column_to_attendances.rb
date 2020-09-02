class RenameAppliedIdColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :applied_id, :applied_overwork
  end
end
