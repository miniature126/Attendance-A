class ChangeDefaultApprovalSuperiorConfirmationToApprovals < ActiveRecord::Migration[5.1]
  def change
    def up
      change_column :approvals, :approval_superior_confirmation, :integer, default: nil
    end
    
    def down
      change_column :approvals, :approval_superior_confirmation, :integer, default: 1
    end
  end
end
