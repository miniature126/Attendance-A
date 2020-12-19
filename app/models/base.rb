class Base < ApplicationRecord

  validates :number, presence: true
  validates :name, presence: true
  validates :attendance_type, presence: true

end
