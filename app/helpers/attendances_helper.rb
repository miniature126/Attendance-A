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
  def overwork_times(desig_finish, overwork, next_day, worked)
    regular_time = worked.midnight.since(desig_finish.seconds_since_midnight) #worked_onの日付とdesig_finish_worktimeの時間を組み合わせる
    if next_day #「翌日」にチェックが入っている時
      format("%.2f",((((overwork.floor_to(15.minute) + 1.day) - regular_time.floor_to(15.minute)) / 60) / 60.0))
    else
      format("%.2f",(((overwork.floor_to(15.minute) - regular_time.floor_to(15.minute)) / 60) / 60.0))
    end
  end
  
  #残業申請情報が存在する場合trueを返す、存在しない場合はfalseを返す
  def overwork_info(user)
    if user.attendances.where(instructor_confirmation: @superior.id).any? #送信者のidが存在する時
      true
    else
      false
    end
  end
        
end
