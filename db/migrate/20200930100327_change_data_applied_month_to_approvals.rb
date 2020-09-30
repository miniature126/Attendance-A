class ChangeDataAppliedMonthToApprovals < ActiveRecord::Migration[5.1]
  def change
    change_column :approvals, :applied_month, :date
  end
end
