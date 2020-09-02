class AddAppliedAttendnacesChangeToAttendnaces < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :applied_attendances_change, :integer
  end
end
