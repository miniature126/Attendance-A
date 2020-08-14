class AddApplicantInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :apply_id, :integer
    add_column :attendances, :applied_id, :integer
  end
end
