class AddReflectionToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_reflection, :boolean
  end
end
