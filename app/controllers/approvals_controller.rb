class ApprovalsController < ApplicationController

  def update
    @user = User.find(params[:user_id])
    @approval = Approval.find(params[:id])
    ActiveRecord::Base.transaction do #トランザクションを用いて更新
      @approval.update_attributes(approval_superior_confirmation: 2)
      @approval.update_attributes!(approval_request_params)
    end
    flash[:success] = "#{@approval.applied_month.month}月分の勤怠を申請しました。"
    redirect_to user_url(@user)
  rescue ActiveRecord::RecordInvalid => e #トランザクションエラー分岐
    debugger
    flash[:danger] = "#{@approval.applied_month.month}月分の勤怠申請をキャンセルしました。未入力項目がないか確認してください。"
    redirect_to user_url(@user)
  end
  
  def edit_approval_superior_notice
    @superior = User.find(params[:user_id])
    @users = User.all
  end
  
  def update_approval_superior_notice
    @superior = User.find(params[:user_id])
    ActiveRecord::Base.transaction do #トランザクション処理開始
      @chancel = []
      @applying = []
      @approval = []
      @denial = []
      approval_notice_params.each do |id, item|
        approval = Approval.find(id)
        if ActiveRecord::Type::Boolean.new.cast(params[:user][:approvals][id][:approval_superior_reflection]) #string型→boolean型へ変更
          case params[:user][:approvals][id][:approval_superior_confirmation].to_i
          when 1 #なし
            if approval.approval_flag #2回目以降の更新の場合
              approval.update_attributes!(approval_superior_confirmation: approval.b_approval_superior_confirmation,
                                          applied_approval_superior: approval.b_applied_approval_superior)
              @chancel << item
            else #初回更新の場合
              approval.update_attributes!(approval_superior_confirmation: nil,
                                          applied_approval_superior: nil)
              @chancel << item
            end
          when 2 #申請中
            @applying << item
          when 3,4 #承認、否認
            if params[:user][:approvals][id][:approval_superior_confirmation].to_i == 3
              @approval << item
            else
              @denial << item
            end
            approval.update_attributes!(item)
            #取り消し処理用に値を保持
            approval.update_attributes!(b_applied_approval_superior: approval.applied_approval_superior,
                                        b_approval_superior_confirmation: approval.approval_superior_confirmation)
            #フラグを立てる。「変更」のチェックを外す
            approval.update_attributes!(approval_flag: true)
          end
          approval.update_attributes!(approval_superior_reflection: false)
        end
      end
    end
    flash[:success] = "所属長承認申請を更新しました。(なし#{@chancel.count}件、申請中#{@applying.count}件、承認#{@approval.count}件、否認#{@denial.count}件)"
    redirect_to user_url(@superior)
  rescue ActiveRecord::RecordInvalid => e #トランザクション例外処理
    flash[:danger] = "無効なデータ入力または未入力項目があった為、更新をキャンセルしました。"
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
