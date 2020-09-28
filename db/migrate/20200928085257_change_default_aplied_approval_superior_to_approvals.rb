class ChangeDefaultApliedApprovalSuperiorToApprovals < ActiveRecord::Migration[5.1]
  def up
    change_column :approvals, :applied_approval_superior, :integer, default: nil
  end
  
  def down
    change_column :approvals, :applied_approval_superior, :integer, default: 1
  end
end
