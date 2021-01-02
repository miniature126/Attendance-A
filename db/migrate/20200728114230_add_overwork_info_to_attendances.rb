class AddOverworkInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :finish_overwork, :datetime
    add_column :attendances, :next_day, :boolean, default: false
    add_column :attendances, :work_contents, :string
    add_column :attendances, :overwork_confirmation, :integer
  end
end
