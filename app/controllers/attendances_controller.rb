class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month] #ユーザー情報を取得
  before_action :logged_in_user, only: [:update, :edit_one_month] #ログイン済みユーザーか確認
  before_action :set_one_month, only: :edit_one_month #1ヶ月分の勤怠データを確認、セット
  before_action :set_attendance_set_user, only: [:edit_overwork_request, :update_overwork_request]

  include AttendancesHelper
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  UPDATE_ERROR_MSG_2 = "無効なデータ入力または未入力項目があった為、更新をキャンセルしました。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    #出勤時間が未登録であることを判定
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
        @user.update_attributes(started_at_flag: true)
        #勤怠変更申請取り消し用処理(「なし」が選択された場合に1つ前の値に戻す際に使用)
        if History.find_by(attendance_id: @attendance.id).present? #取り消し処理用レコードが存在する場合(残業申請が先にされている？)
          @history = History.find_by(attendance_id: @attendance.id)
          @history.update_attributes(b_started_at: @attendance.started_at)
          @attendance.update_attributes(one_month_flag: true)
        else   
          History.create(attendance_id: @attendance.id, b_started_at: @attendance.started_at)
          @attendance.update_attributes(one_month_flag: true)
        end
        #勤怠ログ用処理
        unless @attendance.correction.present?
          @attendance.create_correction(date: @attendance.worked_on,
                                        before_attendance_time: @attendance.started_at,
                                        approval_date: Date.current)
        end
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
        @user.update_attributes(started_at_flag: false)
        #勤怠変更申請取り消し処理用
        @history = History.find_by(attendance_id: @attendance.id)
        @history.update_attributes(b_finished_at: @attendance.finished_at)
        #勤怠ログ用処理
        @correction = @attendance.correction 
        @correction.update_attributes(before_leaving_time: @attendance.finished_at) if @correction.before_leaving_time.nil?
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
    ActiveRecord::Base.transaction do #モデル名.transaction do。複数モデルをいじりたい場合はActiveRecord::Base
      attendances_request_params.each do |id, item|
        attendance = Attendance.find(id) #レコードを探し格納
        if item[:applied_attendances_change].present? #勤怠変更申請先(上長)のidが存在する場合のみ
          @user.designated_work_end_time = attendance.worked_on.midnight.since(@user.designated_work_end_time.seconds_since_midnight)
          @user.save #@userの指定勤務終了時間の日付を申請している日付に合わせる。(合わせないと指定勤務終了時間より早い残業終了予定時間は無効のバリデーションに引っかかる)
          if ActiveRecord::Type::Boolean.new.cast(params[:user][:attendances][id][:next_day]) #翌日チェックありの場合
            attendance.assign_attributes(item)
            attendance.one_day_plus_month
            attendance.save!
          else
            attendance.update_attributes!(item) #翌日チェックなしの場合
          end
          attendance.update_attributes!(change_attendances_confirmation: 2) #ステータスを申請中に
          flash[:success] = "勤怠情報の変更を申請しました。" if flash[:success].nil?
        end
      end
    end
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid => e #トランザクション例外処理
    flash[:danger] = UPDATE_ERROR_MSG_2
    redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
  end
  
  def edit_change_notice #勤怠変更の承認
    @superior = User.find(params[:id]) #送信先に@superiorのidが含まれるため必要
    @users = User.all
  end
  
  def update_change_notice
    @superior = User.find(params[:id]) #送信先に@superiorのidが含まれるため必要
    ActiveRecord::Base.transaction do #トランザクションを開始
      @chancel = []
      @applying = []
      @approval = []
      @denial = []
      attendances_notice_params.each do |id, item|
        attendance = Attendance.find(id)
        #attendanceに紐づくhistoryを取得、なければ生成する
        @history = if History.find_by(attendance_id: attendance.id).present?
                     History.find_by(attendance_id: attendance.id)
                   else   
                     History.create(attendance_id: attendance.id)
                   end
        #「変更」にチェックが入っている時は更新、更新後は変更カラムをfalseに
        if ActiveRecord::Type::Boolean.new.cast(params[:user][:attendances][id][:change_attendances_reflection]) #string型→boolean型に
          case params[:user][:attendances][id][:change_attendances_confirmation].to_i
          when 1 #なし
            if attendance.one_month_flag #2回目以降の申請の場合
              attendance.update_attributes!(started_at: @history.b_started_at,
                                            finished_at: @history.b_finished_at,
                                            next_day: @history.b_next_day,
                                            note: @history.b_note,
                                            applied_attendances_change: @history.b_applied_attendances_change,
                                            change_attendances_confirmation: @history.b_change_attendances_confirmation)
              @chancel << attendance
            else #初回の申請の場合
              attendance.update_attributes!(started_at: nil,
                                            finished_at: nil,
                                            next_day: false,
                                            note: nil,
                                            applied_attendances_change: nil,
                                            change_attendances_confirmation: nil)
              @chancel << attendance
            end
          when 2
            @applying << attendance
          when 3, 4 #承認、否認
            attendance.update_attributes!(item) 
            @history.update_attributes!(b_started_at: attendance.started_at,
                                        b_finished_at: attendance.finished_at,
                                        b_next_day: attendance.next_day,
                                        b_note: attendance.note,
                                        b_applied_attendances_change: attendance.applied_attendances_change,
                                        b_change_attendances_confirmation: attendance.change_attendances_confirmation)
            
            if params[:user][:attendances][id][:change_attendances_confirmation].to_i == 3
              @approval << attendance
            else
              @denial << attendance
            end
            attendance.update_attributes!(one_month_flag: true)
          end
          attendance.update_attributes!(change_attendances_reflection: false)
          #申請中はスルー

          if attendance.change_attendances_confirmation == 3 #ステータスが承認済みの場合のみ(勤怠ログ表示用処理)
            if attendance.correction.present? #勤怠ログが存在する場合
              @correction = attendance.correction
              #変更前の時間が存在しなければ、出勤時間と退勤時間を別カラムに移動し、保持しておく(勤怠ログの変更前時間になる)
              if @correction.before_attendance_time.nil? && @correction.before_leaving_time.nil?
                @correction.update_attributes!(before_attendance_time: @correction.attendance_time,
                                              before_leaving_time: @correction.leaving_time)
              end
              #2回目以降の更新時、before_attendance_timeとbefore_leaving_timeは更新対象に含まない
              @correction.update_attributes!(attendance_time: attendance.started_at,
                                            leaving_time: attendance.finished_at,
                                            instructor: attendance.applied_attendances_change,
                                            approval_date: Date.current)
              attendance.update_attributes!(log_flag: true) #変更あり
            else
              #勤怠変更申請が承認された場合、attendanceのidに紐づくCorrectionモデルのレコードを作成、ログのレコードができたらフラグを立てる
              attendance.create_correction!(date: attendance.worked_on,
                                            attendance_time: attendance.started_at,
                                            leaving_time: attendance.finished_at,
                                            instructor: attendance.applied_attendances_change,
                                            approval_date: Date.current)
              attendance.update_attributes!(log_flag: true) #変更あり
            end
          end
        end
      end     
    end
    flash[:success] = "勤怠変更申請を更新しました。（なし#{@chancel.count}件、申請中#{@applying.count}件、承認#{@approval.count}件、否認#{@denial.count}件）"
    redirect_to user_url(@superior) #リダイレクト先の指定がないと画面が遷移せず固まる。
  rescue ActiveRecord::RecordInvalid => e #トランザクション例外処理
    flash[:danger] = UPDATE_ERROR_MSG_2
    redirect_to user_url(@superior)
  end
  
  # URLのidにはattendanceのidが入っている
  def edit_overwork_request
    @superior = User.where(superior: true).where.not(id: @attendance.user_id)
  end

  def update_overwork_request
    #指定勤務終了時間の日付を残業申請した日の日付に合わせ、保存
    @user.designated_work_end_time = @attendance.worked_on.midnight.since(@user.designated_work_end_time.seconds_since_midnight)
    @user.save
    ActiveRecord::Base.transaction do #トランザクションを開始
      if User.find(params[:user][:attendances][:applied_overwork].to_i).superior? #申請先のユーザー、本当に上長？
        if ActiveRecord::Type::Boolean.new.cast(params[:user][:attendances][:next_day]) #翌日チェックありの場合
          @attendance.assign_attributes(overwork_request_params)
          @attendance.one_day_plus_overwork
          @attendance.save!
        else
          @attendance.update_attributes!(overwork_request_params)
        end
        @attendance.update_attributes!(overwork_confirmation: 2) #残業申請のステータスを「申請中」
      end
      flash[:success] = "#{l(@attendance.worked_on, format: :date)}の残業を申請しました。"
      redirect_to user_url(@user)

    rescue ActiveRecord::RecordInvalid => e #トランザクションエラー分岐
      flash[:danger] = UPDATE_ERROR_MSG_2
      redirect_to user_url(@user)
    end
      
  end
  
  def edit_overwork_notice
    @superior = User.find(params[:id]) #なんでこのidはAttendanceのidじゃなくてUserのid？→ルーティング見直しの必要あり！
    @users = User.all
  end
  
  def update_overwork_notice
    @superior = User.find(params[:id])
    ActiveRecord::Base.transaction do #トランザクションを開始
      @chancel = []
      @applying = []
      @approval = []
      @denial = []
      overwork_notice_params.each do |id, item| #update_one_monthアクション参考
        attendance = Attendance.find(id)
        #attendanceに紐づくhistoryを取得、なければ生成する
        @history = if History.find_by(attendance_id: attendance.id).present?
                     History.find_by(attendance_id: attendance.id)
                   else   
                     History.create(attendance_id: attendance.id)
                   end
        user = User.find_by(id: attendance.user_id)
        user.designated_work_end_time = attendance.worked_on.midnight.since(user.designated_work_end_time.seconds_since_midnight)
        user.save #基本時間の日付を残業申請日に合わせて変更、保存
        if ActiveRecord::Type::Boolean.new.cast(params[:user][:attendances][id][:overwork_reflection]) #string型→boolean型に(:overwork_reflection→「変更」)
          case params[:user][:attendances][id][:overwork_confirmation].to_i
          when 1 #なし
            if attendance.overwork_flag #2回目以降の残業申請の場合、1つ前の値に戻す
              attendance.update_attributes!(finish_overwork: @history.b_finish_overwork,
                                            next_day: @history.b_next_day,
                                            work_contents: @history.b_work_contents,
                                            applied_overwork: @history.b_applied_overwork,
                                            overwork_confirmation: @history.b_overwork_confirmation)
              @chancel << attendance
            else #初回の残業申請の場合、残業申請に関わるカラムの値を全て空にする(翌日はfalseに)
              attendance.update_attributes!(finish_overwork: nil,
                                            next_day: false,
                                            work_contents: nil,
                                            applied_overwork: nil,
                                            overwork_confirmation: nil)
              @chancel << attendance
            end
          when 2
            @applying << attendance
          when 3, 4 #承認、否認
            attendance.update_attributes!(item) #パラメータの情報を基にカラムの値を更新
            @history.update_attributes!(b_finish_overwork: attendance.finish_overwork,
                                        b_next_day: attendance.next_day,
                                        b_work_contents: attendance.work_contents,
                                        b_applied_overwork: attendance.applied_overwork,
                                        b_overwork_confirmation: attendance.overwork_confirmation)
            if params[:user][:attendances][id][:overwork_confirmation].to_i == 3
              @approval << attendance
            else
              @denial << attendance
            end
            attendance.update_attributes!(overwork_flag: true)
          end
          #2(申請中)はスルー
          attendance.update_attributes!(overwork_reflection: false)
        end
      end
    end
    flash[:success] = "残業申請を更新しました。（なし#{@chancel.count}件、申請中#{@applying.count}件、承認#{@approval.count}件、否認#{@denial.count}件）"
    redirect_to user_url(@superior)
  rescue ActiveRecord::RecordInvalid => e #トランザクションエラー分岐
    flash[:danger] = UPDATE_ERROR_MSG_2
    redirect_to user_url(@superior)
  end
  
  private
    #beforeフィルター
    #idの値が一致するレコード、レコードのuser_idをもとにユーザー情報を取得
    def set_attendance_set_user
      @attendance = Attendance.find(params[:id])
      @user = User.find(@attendance.user_id)
    end

    #一般→上長(上長→上長)と、#上長→一般(上長→上長)でストロングパラメータを分ける
    #勤怠変更申請情報(申請者→上長)を扱う
    def attendances_request_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :next_day, :note, :applied_attendances_change])[:attendances]
    end

    #勤怠変更申請情報(上長→申請者)を扱う
    def attendances_notice_params
      params.require(:user).permit(attendances: [:change_attendances_confirmation, :change_attendances_reflection])[:attendances]
    end
    
    #残業申請情報(申請者→上長)を扱う
    def overwork_request_params
      params.require(:user).permit(attendances: [:finish_overwork, :next_day, :work_contents, :applied_overwork])[:attendances]
    end

    #残業申請情報(上長→申請者)を扱う
    def overwork_notice_params
      params.require(:user).permit(attendances: [:overwork_confirmation, :overwork_reflection])[:attendances]      
    end
end
