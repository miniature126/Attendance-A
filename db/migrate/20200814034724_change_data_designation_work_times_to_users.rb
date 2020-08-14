class ChangeDataDesignationWorkTimesToUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :desig_start_worktime, :datetime, default: Time.current.change(hour: 8, min: 0, sec: 0)
    change_column :users, :desig_finish_worktime, :datetime, default: Time.current.change(hour: 17, min: 0, sec: 0)
  end
end
