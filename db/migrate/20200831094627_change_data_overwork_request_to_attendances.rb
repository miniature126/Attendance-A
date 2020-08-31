class ChangeDataOverworkRequestToAttendances < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :overwork_request, :boolean, default: false
  end
end
