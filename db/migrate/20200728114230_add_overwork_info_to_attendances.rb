class AddOverworkInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :finish_overtime, :datetime
    add_column :attendances, :next_day, :datetime
    add_column :attendances, :work_content, :string
    add_column :attendances, :instructor_confirmation, :string
  end
end
