module BasesHelper
  def type_display(attendance)
    if attendance == 0
      "出勤"
    elsif attendance == 1
      "退勤"
    end
  end
end
