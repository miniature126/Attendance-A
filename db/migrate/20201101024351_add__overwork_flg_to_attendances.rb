class AddOverworkFlgToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_flag, :boolean, default: false
  end
end
