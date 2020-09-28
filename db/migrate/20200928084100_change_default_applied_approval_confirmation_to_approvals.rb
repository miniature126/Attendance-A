class ChangeDefaultAppliedApprovalConfirmationToApprovals < ActiveRecord::Migration[5.1]
  def up
    change_column :approvals, :approval_superior_confirmation, :integer, default: 1
  end
  
  def down
    change_column :approvals, :approval_superior_confirmation, :integer
  end
end
