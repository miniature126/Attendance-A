class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  #出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  #出勤時間が存在しない場合、残業申請は無効
  # validate :overwork_time_is_invalid_without_a_started_at
  #出勤・退勤時間がどちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_then_finished_at_fast_if_invalid
  #当日の勤怠データが存在する時、出勤時間のみの更新は無効
  validate :started_at_is_invalid_without_a_finished_at
  
  validates :finish_overwork, presence: true
  validates :next_day, inclusion: { in: [true, false] }
  validates :work_contents, presence: true
  validates :instructor_confirmation, presence: true
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  # def overwork_time_is_invalid_without_a_started_at
  #   errors.add(:started_at, "が必要です") if started_at.blank? && overwork_time.present?
  # end
  
  def started_at_then_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い時間は無効です") if started_at > finished_at
    end
  end
  
  #出勤日当日でない日は、出勤時間のみの更新は無効
  def started_at_is_invalid_without_a_finished_at
    unless worked_on == Date.current
      errors.add(:finished_at, " が必要です") if started_at.present? && finished_at.blank?
    end
  end
end
