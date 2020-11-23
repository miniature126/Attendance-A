class RenameDesignationWorktimeToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :desig_start_worktime, :designated_work_start_time
    rename_column :users, :desig_finish_worktime, :designated_work_end_time
  end
end
