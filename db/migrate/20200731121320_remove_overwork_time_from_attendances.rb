class RemoveOverworkTimeFromAttendances < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :overwork_time, :datetime
  end
end
