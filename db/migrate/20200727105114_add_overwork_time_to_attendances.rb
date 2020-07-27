class AddOverworkTimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_time, :datetime
  end
end
