class ChangeDataAppliedMonthToApprovals < ActiveRecord::Migration[5.1]
  def up
    change_column :approvals, :applied_month, :date
  end
end
