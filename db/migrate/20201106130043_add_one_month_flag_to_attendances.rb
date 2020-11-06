class AddOneMonthFlagToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :one_month_flag, :boolean, default: false
  end
end
