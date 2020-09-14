class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  #残業申請、承認
  #勤怠変更申請、承認
  
  
  #出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  #出勤・退勤時間がどちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_then_finished_at_fast_if_invalid
  #当日の勤怠データが存在する時、出勤時間のみの更新は無効
  validate :started_at_is_invalid_exist_a_finished_at
  #退勤時間が存在する時、終了予定時間の更新は無効
  # validate :finish_overwork_is_invalid_exist_a_finished_at
  #指定勤務終了時間より早い残業終了予定時間は無効
  validate :finish_overwork_earlier_than_desig_finish_worktime_is_invalid
  #残業終了予定時間が存在する時、業務処理内容と残業申請送信先も同じく存在する
  validate :finish_overwork_exist_work_contents_applied_overwork_exist
  #残業申請送信先に上長以外のユーザーは指定できない
  # validate :destination_cannot_specified_other_than_superior_overwork
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_then_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い時間は無効です") if started_at > finished_at
    end
  end
  
  #出勤日当日でない日は、出勤時間のみの更新は無効
  def started_at_is_invalid_exist_a_finished_at
    unless worked_on == Date.current
      errors.add(:finished_at, " が必要です") if started_at.present? && finished_at.blank?
    end
  end
  
  # def finish_overwork_is_invalid_exist_a_finished_at
  #   errors.add("退勤しているので、残業申請は無効です") if finished_at.present? && finish_overwork.present?
  # end
  
  #指定勤務終了時間より早い残業終了予定時間は無効
  def finish_overwork_earlier_than_desig_finish_worktime_is_invalid
    if user.desig_finish_worktime > finish_overwork
      errors.add(:desig_finish_worktime, "より早い時間は無効です")
    end
  end
  
  #残業終了予定時間が存在する時、業務処理内容と残業申請送信先も同じく存在する
  def finish_overwork_exist_work_contents_applied_overwork_exist
    if finish_overwork.present?
      unless work_contents.present? && applied_overwork.present?
        errors.add(:work_contents, "が必要です")
        errors.add(:applied_overwork, "が必要です")
      end
    end
  end
  
  #残業申請先には上長しか選択できない
  # def destination_cannot_specified_other_than_superior_overwork
  #   if applied_overwork.present?
  #     unless User.find(:applied_overwork).superior? #←動かない。ユーザー呼べてない。
  #       errors.add("上長ユーザーを選択して下さい")
  #     end
  #   end
  # end
  
end
