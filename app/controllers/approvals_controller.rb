class ApprovalsController < ApplicationController
  # before_action :set_user, only: [:edit_approval_superior_notice, :update_approval_superior_notice]
  
  def update
    #トランザクションを用いて更新
  end
  
  def edit_approval_superior_notice
    @superior = User.find(params[:user_id])
  end
  
  def update_approval_superior_notice
  end

  private
    #一般→上長(上長→上長)の1ヶ月分の勤怠申請情報を扱う
    def approval_request_params
      params.require(:user).permit(approvals: [:applied_approval_superior])[:approvals]
    end

    #一般→上長(上長→上長)の1ヶ月分の勤怠申請情報を扱う
    def approval_notice_params
      params.require(:user).permit(approvals: [:approval_superior_confirmation, :approval_superior_reflection])[:approvals]
    end
end
