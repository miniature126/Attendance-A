module ApprovalHelper
  #ユーザーが通知を開いている上長に対しての申請情報を持っているか判断する
  def approval_superior_application_info(user, superior)
    if user.approvals.where(applied_approval_superior: superior.id).where(approval_superior_confirmation: 2).any?
        true
    else
        false
    end
  end

   #所属長承認欄の表示
  def approval_confirmation_state(superior, applied_approval, approval_confirmation)
    if applied_approval == superior.id  #上長のidが申請先のidと等しい場合 
      case approval_confirmation
      when 2 
        return "#{superior.name}へ申請中"
      when 3 
        return "#{superior.name}より承認済"
      when 4 
        return "#{superior.name}より否認"
      end
    end
  end
end
