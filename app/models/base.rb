class Base < ApplicationRecord

  validates :base_name, presence: true
  validates :attendance_type, presence: true

end
