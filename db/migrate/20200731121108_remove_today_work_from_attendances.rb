class RemoveTodayWorkFromAttendances < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :today_work, :boolean
  end
end
