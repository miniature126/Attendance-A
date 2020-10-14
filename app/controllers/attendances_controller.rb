class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :superior_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  before_action :set_attendance_user, only: [:edit_overwork_request, :update_overwork_request]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    #出勤時間が未登録であることを判定
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        #勤怠ログ表示用のレコードを作成(日付と出勤時間のみ)
        @attendance.create_correction(date: @attendance.worked_on, attendance_time: @attendance.started_at)
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        #勤怠ログ表示用のレコードを更新(退勤時間)
        @attendance.correction.update_attributes(leaving_time: @attendance.finished_at)
        debugger
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
    @superior = User.where(superior: true).where.not(id: params[:id])
  end
  
  def update_one_month #勤怠変更の申請
    ActiveRecord::Base.transaction do #モデル名.transaction do。複数モデルをいじりたい場合はActiveRecord::Base。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id) #レコードを探し格納
        if item[:applied_attendances_change].present? #勤怠変更申請先(上長)のidが存在する場合のみ
          @user.desig_finish_worktime = attendance.worked_on.midnight.since(@user.desig_finish_worktime.seconds_since_midnight)
          @user.save #@userの指定勤務終了時間の日付を申請している日付に合わせる。合わせないと指定勤務終了時間より早い残業終了予定時間は無効のバリデーションに引っかかる
          if attendance.started_at.present? && attendance.finished_at.present? #既に出勤時間と退勤時間が存在する時
            attendance.started_at_before_change = attendance.started_at #出勤時間を変更前出勤時間カラムに移動
            attendance.finished_at_before_change = attendance.finished_at #退勤時間を変更前退勤時間カラムに移動
            attendance.save
          end
          attendance.change_attendances_confirmation = 2 #ステータスを申請中にする
          attendance.save
          attendance.update_attributes!(item) #入力データ上書き
          if attendance.correction.present? #create後初回の更新
            @correction = Correction.includes(:attendance).find_by(id: attendance.id) #既に存在するcorrectionモデルのレコードを引っ張る
            #初回の更新の場合は、一番最初に登録した出勤時間と退勤時間を別カラムに移動し、保持しておく
            unless @correction.before_attendance_time.present? && @correction.before_leaving_time.present?
              @correction.before_attendance_time = @correction.attendance_time
              @correction.before_leaving_time = @correction.leaving_time
              @correction.save
            end
            #2回目以降の更新時、before_attendance_timeとbefore_leaving_timeは更新対象に含まない
            @correction.update_attributes!(attendance_time: attendance.started_at,
                                           leaving_time: attendance.finished_at,
                                           instructor: attendance.applied_attendances_change,
                                           approval_date: Date.current)
          else
            #出勤ボタン・退勤ボタンで勤怠が入力されていなかった場合、attendanceのidに紐づくCorrectionモデルのレコードを作成
            attendance.create_correction!(date: attendance.worked_on,
                                          attendance_time: attendance.started_at,
                                          leaving_time: attendance.finished_at,
                                          instructor: attendance.applied_attendances_change,
                                          approval_date: Date.current)
          end
        end
        #worked_on, started_at(started_at_before_change), finished_at(finished_at_before_change),
        #applied_attendances_change, approval_date(currentで良い？)の情報を上書き
        #保存
      end
    end
    flash[:success] = "勤怠情報の変更を申請しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid #トランザクション例外処理
    flash[:danger] = "無効なデータ入力、または未入力項目があった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
  end
  
  def edit_change_notice #勤怠変更の承認
    @superior = User.find(params[:id]) #送信先に@superiorのidが含まれるため必要
    @users = User.all
  end
  
  def update_change_notice
    @superior = User.find(params[:id]) #送信先に@superiorのidが含まれるため必要
    ActiveRecord::Base.transaction do #トランザクションを開始
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        #「変更」にチェックが入っている時は更新
        attendance.update_attributes!(item) if ActiveRecord::Type::Boolean.new.cast(params[:user][:attendances][id][:change_attendances_reflection]) #string型→boolean型に
      end     
    end  
    flash[:success] = "勤怠変更申請の情報を更新しました。"
    redirect_to user_url(@superior) #リダイレクト先の指定がないと画面が遷移せず固まる。
  rescue ActiveRecord::RecordInvalid #トランザクション例外処理
    flash[:danger] = "更新をキャンセルしました。"
    redirect_to user_url(@superior)
  end
  
  # URLのidにはattendanceのidが入っている
  def edit_overwork_request
    @attendance = Attendance.find(params[:id]) #paramsから取得したユーザー
    @superior = User.where(superior: true).where.not(id: @attendance.user_id)
  end

  def update_overwork_request
    #指定勤務終了時間の日付を残業申請した日の日付に合わせ、保存
    @user.desig_finish_worktime = @attendance.worked_on.midnight.since(@user.desig_finish_worktime.seconds_since_midnight)
    @user.save
    params[:user][:attendances][:overwork_confirmation] = 2 #残業申請のステータスを「申請中」
    if User.find(params[:user][:attendances][:applied_overwork]).superior? #申請先のユーザー、本当に上長？
      if @attendance.update_attributes(overwork_params)
        flash[:success] = "残業を申請しました。"
      else
        flash[:danger] = "申請をキャンセルしました。"
      end
    end
    redirect_to user_url(@user)
  end
  
  def edit_overwork_notice
    @superior = User.find(params[:id]) #なんでこのidはAttendanceのidじゃなくてUserのid？→ルーティング見直しの必要あり！
    @users = User.all
  end
  
  def update_overwork_notice
    @superior = User.find(params[:id])
    ActiveRecord::Base.transaction do #トランザクションを開始
      overwork_params.each do |id, item| #update_one_monthアクション参考
        attendance = Attendance.find(id)
        user = User.find_by(id: attendance.user_id)
        user.desig_finish_worktime = attendance.worked_on.midnight.since(user.desig_finish_worktime.seconds_since_midnight)
        user.save #基本時間の日付を残業申請日に合わせて変更、保存
        attendance.update_attributes!(item) if ActiveRecord::Type::Boolean.new.cast(params[:user][:attendances][id][:overwork_reflection]) #string型→boolean型に(:overwork_reflection→「変更」)
      end
    end
    flash[:success] = "情報を更新しました。"
    redirect_to user_url(@superior)
  rescue ActiveRecord::RecordInvalid #トランザクションエラー分岐
    flash[:danger] = "無効なデータがあった為、更新をキャンセルしました。"
    redirect_to user_url(@superior)
  end
  
  private
    #beforeフィルター
    #idの値が一致するレコード、レコードのuser_idをもとにユーザー情報を取得
    def set_attendance_user
      @attendance = Attendance.find(params[:id])
      @user = User.find(@attendance.user_id)
    end
    
    #一般→上長(上長→上長)と、#上長→一般(上長→上長)でストロングパラメータを分ける
    #１ヶ月分の勤怠申請情報を扱う
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :applied_attendances_change, :change_attendances_confirmation, :change_attendances_reflection])[:attendances]
    end
    
    #残業申請情報を扱う
    def overwork_params
      params.require(:user).permit(attendances: [:finish_overwork, :next_day, :work_contents, :applied_overwork, :overwork_confirmation, :overwork_reflection])[:attendances]
    end
end
