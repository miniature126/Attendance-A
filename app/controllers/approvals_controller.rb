class ApprovalsController < ApplicationController
  # before_action :set_user, only: [:edit_approval_superior_notice, :update_approval_superior_notice]
  
  def new
    #トランザクションを用いて更新
  end

  def create
  end
  
  def edit
    @superior = User.find(params[:user_id])
  end
  
  def update
  end

  private
    #1ヶ月分の勤怠申請情報を扱う
    def approval_params
      params.require(:user).permit(approvals: [:applied_approval_superior, :approval_confirmation, :approval_superior_reflection])[:approvals]
    end
end
