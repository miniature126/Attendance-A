class Approval < ApplicationRecord
  belongs_to :user
  
  validates :applied_month, presence: true

  #申請時は所属長(上長)の選択が必要
  validate :select_superior_at_application

  def select_superior_at_application
    errors.add(:applied_approval_superior, "を選択してください") if approval_superior_confirmation == 2 && applied_approval_superior.nil?
  end
end
