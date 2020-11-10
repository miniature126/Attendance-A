class Approval < ApplicationRecord
  belongs_to :user
  
  validates :applied_month, presence: true
  validates :approval_superior_confirmation, presence: true, on: :update
  validates :applied_approval_superior, presence: true, on: :update
end
