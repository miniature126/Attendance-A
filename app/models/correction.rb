class Correction < ApplicationRecord

  include ActiveRecord::AttributeAssignment

  attribute :date

  belongs_to :attendance

  validates :date, presence: true
  validates :instructor, presence: true, on: :update_one_month
  validates :approval_date, presence: true, on: :update_one_month

  #変更前出勤時間より早い変更前退勤時間は無効
  validate :before_leaving_time_earlier_than_before_attendance_time_is_invalid
  #出勤時間より早い退勤時間は無効
  validate :leaving_time_earlier_than_attendance_time_is_invalid

  def before_leaving_time_earlier_than_before_attendance_time_is_invalid
    if before_leaving_time.present? && before_attendance_time.present?
      errors.add(:before_attendance_time, "より早い時間は無効です") if before_leaving_time <= before_attendance_time
    end
  end

  def leaving_time_earlier_than_attendance_time_is_invalid
    if leaving_time.present? && attendance_time.present?
      errors.add(:attendance_time, "より早い時間は無効です") if leaving_time <= attendance_time
    end
  end
end
