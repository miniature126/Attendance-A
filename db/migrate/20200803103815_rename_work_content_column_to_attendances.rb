class RenameWorkContentColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :work_content, :work_contents 
  end
end
