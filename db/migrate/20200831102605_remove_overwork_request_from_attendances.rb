class RemoveOverworkRequestFromAttendances < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :overwork_request, :boolean
  end
end
