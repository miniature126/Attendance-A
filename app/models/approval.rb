class Approval < ApplicationRecord
  belongs_to :user
  
  validates :applied_month, presence: true
  validates :applied_approval_superior, presence: true, on: :update
end
