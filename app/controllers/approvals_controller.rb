class ApprovalsController < ApplicationController
  # before_action :set_user, only: [:edit_approval_superior_notice, :update_approval_superior_notice]
  
  def update_approval_superior_request
    #トランザクションを用いて更新
  end
  
  def edit_approval_superior_notice
    @superior = User.find(params[:user_id])
  end
  
  def update_approval_superior_notice
  end

  private
    #1ヶ月分の勤怠申請情報を扱う
    def approval_params
      params.require(:user).permit(approvals: [:applied_approval_superior, :approval_confirmation, :approval_superior_reflection])[:approvals]
    end
end
