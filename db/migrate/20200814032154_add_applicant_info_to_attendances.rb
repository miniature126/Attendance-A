class AddApplicantInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :applied_overwork, :integer
  end
end
