class ApprovalsController < ApplicationController
  
  def update
    @user = User.find(params[:user_id])
    @approval = Approval.find(params[:id])
    ActiveRecord::Base.transaction do #トランザクションを用いて更新
      @approval.approval_superior_confirmation = 2
      @approval.save
      @approval.update_attributes!(approval_request_params)
    end
    flash[:success] = "#{@approval.applied_month.month}月分の勤怠を申請しました。"
    redirect_to user_url(@user)
  rescue ActiveRecord::RecordInvalid #トランザクションエラー分岐
    flash[:danger] = "#{@approval.applied_month.month}月分の勤怠申請をキャンセルしました。"
    redirect_to user_url(@user)
  end
  
  def edit_approval_superior_notice
    @superior = User.find(params[:user_id])
    @users = User.all
  end
  
  def update_approval_superior_notice
    @superior = User.find(params[:user_id])
    ActiveRecord::Base.transaction do #トランザクション処理開始
      approval_notice_params.each do |id, item|
        approval = Approval.find(id)
        approval.update_attributes!(item) if ActiveRecord::Type::Boolean.new.cast(params[:user][:approvals][id][:approval_superior_reflection]) #string型→boolean型へ変更
      end
    end
    flash[:success] = "1ヶ月分の勤怠申請情報を更新しました。"
    redirect_to user_url(@superior)
  rescue ActiveRecord::RecordInvalid #トランザクション例外処理
    flash[:danger] = "無効なデータがあった為、更新をキャンセルしました。"
    redirect_to user_url(@superior)
  end

  private
    #一般→上長(上長→上長)の1ヶ月分の勤怠申請情報を扱う
    def approval_request_params
      params.require(:approval).permit(:applied_approval_superior)
    end

    #一般→上長(上長→上長)の1ヶ月分の勤怠申請情報を扱う
    # f.fields_for "approvals[]", day do |approval|←この部分が.permit(〇〇: 〜)と一緒
    def approval_notice_params
      params.require(:user).permit(approvals: [:approval_superior_confirmation, :approval_superior_reflection])[:approvals]
    end
end
