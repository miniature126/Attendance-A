class RenameAppliedOnColumnToApprovals < ActiveRecord::Migration[5.1]
  def change
    rename_column :approvals, :applied_on, :applied_month
  end
end
