class ApprovalsController < ApplicationController
  
  def update
    @user = User.find(params[:user_id])
    @approval = Approval.find(params[:id])
    # if User.find(params[:approval][:applied_approval_superior]).superior?
    #   if @approval.update_attributes(approval_request_params)
    #     flash[:success] = "#{@approval.applied_month.month}月の勤怠を申請しました。"
    #   else
    #     flash[:danger] = "#{@approval.applied_month.month}月の勤怠申請をキャンセルしました。"
    #   end
    # end
    ActiveRecord::Base.transaction do #トランザクションを用いて更新
      @approval.approval_superior_confirmation = 2
      @approval.save
      @approval.update_attributes!(approval_request_params)
    end
    flash[:success] = "#{@approval.applied_month.month}月の勤怠承認を申請しました。"
    redirect_to user_url(@user)
  rescue ActiveRecord::RecordInvalid #トランザクションエラー分岐
    flash[:danger] = "#{@approval.applied_month.month}月の勤怠申請をキャンセルしました。"
    redirect_to user_url(@user)
  end
  
  def edit_approval_superior_notice
    @superior = User.find(params[:user_id])
  end
  
  def update_approval_superior_notice
  end

  private
    #一般→上長(上長→上長)の1ヶ月分の勤怠申請情報を扱う
    def approval_request_params
      params.require(:approval).permit(:applied_approval_superior)
    end

    #一般→上長(上長→上長)の1ヶ月分の勤怠申請情報を扱う
    def approval_notice_params
      params.require(:user).permit(approvals: [:approval_superior_confirmation, :approval_superior_reflection])[:approvals]
    end
end
