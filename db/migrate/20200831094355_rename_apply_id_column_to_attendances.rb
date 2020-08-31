class RenameApplyIdColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :apply_id, :overwork_request
  end
end
