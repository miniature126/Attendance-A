class AddOverworkFlgToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_flg, :boolean, default: false
  end
end
