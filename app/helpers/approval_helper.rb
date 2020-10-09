module ApprovalHelper
  #ユーザーが通知を開いている上長に対しての申請情報を持っているか判断する
  def approval_superior_application_info(user, superior)
    if user.approvals.where(applied_approval_superior: superior.id).where(approval_superior_confirmation: 2).any?
        true
    else
        false
    end
  end
end
