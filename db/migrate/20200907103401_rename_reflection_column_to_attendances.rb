class RenameReflectionColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :reflection, :overwork_reflection
  end
end
