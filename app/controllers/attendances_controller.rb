class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :set_superior, only: [:edit_overwork_request]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  before_action :set_attendance_user, only: [:edit_overwork_request, :update_overwork_request]
  
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
  
  # URLのidにはattendanceのidが入っている
  def edit_overwork_request
  end

  def update_overwork_request
    if @attendance.update_attributes(overwork_request_params)
      flash[:success] = "残業を申請しました。"
    else
      flash[:danger] = "申請をキャンセルしました。"
    end
    redirect_to user_url(@user)
  end
  
  def edit_overwork_notice
    @superior = User.find(params[:id]) #なんでこのidはAttendanceのidじゃなくてUserのid？
    @users = User.all
  end
  
  def update_overwork_notice
    @superior = User.find(params[:id])
    overwork_notice_params.each do |id, item| #update_one_monthアクション参考
      @attendance = Attendance.find(id)
      ref = params[:user][:attendances][id][:reflection]
      #refはstring型なのでboolean型に変換
      if ActiveRecord::Type::Boolean.new.cast(ref)
        if @attendance.update_attributes(item)
          flash[:success] = "情報を更新しました。"
        else
          flash[:danger] = "更新をキャンセルしました。"
        end
      end
      ref = nil
    end
    redirect_to user_url(@superior)
  end
    
  private
    #beforeフィルター
    #idの値が一致するレコード、レコードのuser_idをもとにユーザー情報を取得
    def set_attendance_user
      @attendance = Attendance.find(params[:id])
      @user = User.find(@attendance.user_id)
    end
    
    #１ヶ月分の勤怠情報を扱う
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    #残業申請情報を扱う
    def overwork_request_params
      params.require(:user).permit(attendances: [:finish_overwork, :next_day, :work_contents, :apply_id, :applied_id])[:attendances]
    end
    
    #残業申請お知らせ情報を扱う
    def overwork_notice_params
      params.require(:user).permit(attendances: [:instructor_confirmation, :reflection])[:attendances]
    end
    
end
