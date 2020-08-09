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
  
  #出勤時間と終了予定時間を受け取り、時間外時間を計算して返す
  def overwork_times(start, finish, worked_on, basic_time, next_day)
    basic_time_today = Time.local(worked_on.year, worked_on.month, worked_on.day, basic_time.hour, basic_time.min, basic_time.sec)
    regular_time = start + basic_time_today
    format("%.2f", (((finish - regular_time) / 60) / 60.0))
    # if next_day
    #   format("%.2f", ((((overwork.floor_to(15.minute) + 1.day) - finish.floor_to(15.minute)) / 60) / 60.0))
    # else
    #   format("%.2f", (((overwork.floor_to(15.minute) - finish.floor_to(15.minute)) / 60) / 60.0))
    # end
  end
end
