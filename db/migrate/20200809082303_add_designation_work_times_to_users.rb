class AddDesignationWorkTimesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :desig_start_worktime, :datetime
    add_column :users, :desig_finish_worktime, :datetime
  end
end
