class AddOneMonthToHistories < ActiveRecord::Migration[5.1]
  def change
    add_column :histories, :b_note, :string
    add_column :histories, :b_applied_attendances_change, :integer
  end
end
