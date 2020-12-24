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
  def method_name
    
  end

  #指示者確認印欄の表示(勤怠変更申請)
  def method_name
    
  end

  #指示者確認印欄の表示(1ヶ月勤怠申請)
  def method_name
    
  end
end
