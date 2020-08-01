class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    #出勤時間が未登録であることを判定
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do #トランザクションを開始
      attendances_params.each do |id, item|
        attendance = Attendance.find(id) #レコードを探し格納
        attendance.update_attributes!(item) #入力データ上書き
      end
    end
    flash[:success] = "１ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid #トランザクションによるエラー分岐
    flash[:danger] = "無効なデータ入力があった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
  end
  
  def edit_overwork_request
    # URLのidにはattendanceのidが入っている
    @attendance = Attendance.find(params[:id]) #idの値が一致するレコードを探してくる
    @user = User.find(@attendance.user_id) #上記レコードのuser_idをもとにユーザー情報を探してくる
  end

  def update_overwork_request
    @attendance = Attendance.find(params[:id])
    @user = User.find(@attendance.user_id)
    if @attendance.update_attributes(overwork_params)
      flash[:success] = "残業を申請しました。"
    else
      flash[:danger] = "無効なデータ入力があった為、申請をキャンセルしました。"
    end
    redirect_to user_url(@user)
  end
  
  def show_overwork_notice
    
  end
  
  private
    #１ヶ月分の勤怠情報を扱う
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    #残業情報を扱う
    def overwork_params
      params.require(:attendance).permit(:finish_overwork, :next_day, :work_content, :instuctor_confirmation)
    end
end
