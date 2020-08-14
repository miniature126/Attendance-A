class ChangeDefaultDesignationWorkTimeToUsers < ActiveRecord::Migration[5.1]
  def up
    change_column :users, :desig_start_worktime, :integer, default: Time.current.change(hour: 8, min: 0, sec: 0)
    change_column :users, :desig_finish_worktime, :integer, default: Time.current.change(hour: 17, min: 0, sec: 0)
  end
  
  def down
    change_column :users, :desig_start_worktime, :integer
    change_column :users, :desig_finish_worktime, :integer
  end
end
