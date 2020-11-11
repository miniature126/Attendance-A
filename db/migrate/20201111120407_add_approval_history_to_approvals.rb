class AddApprovalHistoryToApprovals < ActiveRecord::Migration[5.1]
  def change
    add_column :approvals, :b_applied_approval_superior, :integer
    add_column :approvals, :b_approval_superior_confirmation, :integer
  end
end
