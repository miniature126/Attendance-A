class AddApprovalFlagToApprovals < ActiveRecord::Migration[5.1]
  def change
    add_column :approvals, :approval_flag, :boolean, default: false
  end
end
