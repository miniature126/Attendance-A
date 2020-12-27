module AttendancesHelper
  
  def attendance_state(attendance)
    #受け取ったAttendanceオブジェクトが当日と一致するか評価する
    if Date.current == attendance.worked_on
      return "出勤" if attendance.started_at.nil?
      return "退勤" if attendance.started_at.present? && attendance.finished_at.nil?
    end
    #どれにも当てはまらなかった場合はfalseを返す
    false
  end
  
  #出勤時間と退勤時間を受け取り、在社時間を計算して返す
  def working_times(start, finish)
    format("%.2f", (((finish.floor_to(15.minute) - start.floor_to(15.minute)) / 60) / 60.0))
  end
  
  #指定勤務終了時間と終了予定時間を受け取り、時間外時間を計算して返す
  def overwork_times(desig_end, overwork, worked)
    regular_time = worked.midnight.since(desig_end.seconds_since_midnight) #worked_onの日付とdesignated_work_end_timeの時間を組み合わせる
    format("%.2f",(((overwork.floor_to(15.minute) - regular_time.floor_to(15.minute)) / 60) / 60.0))
  end
  
  #残業申請中のレコードが存在する場合true、存在しない場合はfalseを返す
  def overwork_application_info(user, superior)
    if user.attendances.where(applied_overwork: superior.id).where(overwork_confirmation: 2).any?
      true
    else
      false
    end
  end
  
  #勤怠変更申請中のレコードが存在する場合はtrue、存在しない場合はfalseを返す
  def change_attendance_application_info(user, superior)
    if user.attendances.where(applied_attendances_change: superior.id).where(change_attendances_confirmation: 2).any?
      true
    else
      false
    end
  end

  #指示者確認印欄の表示(残業申請)
  def overwork_confirmation_state(superior, applied_overwork, overwork_confirmation) 
    if applied_overwork == superior.id #申請先上長idが、@superiorで取得した上長idと等しい場合
      case overwork_confirmation
      when 2
        return "#{superior.name}へ残業申請中"
      when 3 
        return "#{superior.name}より残業承認済"
      when 4 
        return "#{superior.name}より残業否認"
      end
    end
  end

  #残業申請と勤怠変更申請の区切り
  def separation(overwork_confirmation, change_confirmation)
    return "／" if overwork_confirmation.present? && change_confirmation.present?
  end

  #指示者確認印欄の表示(勤怠変更申請)
  def change_confirmation_state(superior, applied_change, change_confirmation)   
    if applied_change == superior.id 
      case change_confirmation 
      when 2 
        return "#{superior.name}へ勤怠変更申請中"
      when 3 
        return "#{superior.name}より勤怠変更承認済"
      when 4 
        return "#{superior.name}より勤怠変更否認"
      end
    end
  end
end
