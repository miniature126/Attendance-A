class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  
  attr_accessor :remember_token #仮想の属性（remember_token）を作成
  before_save { self.email = email.downcase }
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :department, length: { in: 2..30 }, allow_blank: true
  validates :basic_time, presence: true
  validates :desig_start_worktime, presence: true
  validates :desig_finish_worktime, presence: true
  validates :employee_number, presence: true, allow_blank: true
  validates :card_id, presence: true, allow_blank: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  #渡された文字列のハッシュ値(一見適当に見える値)を返す
  def User.digest(string)
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end
  
  #ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  #永続セッションのためハッシュ化したトークンをデータベースに記憶
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  #トークンがダイジェストと一致すればtrueを返す
  def authenticated?(remember_token)
    #ダイジェストが存在しない場合はfalseを返して終了
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  #rememberメソッドで記憶したユーザーログイン情報を破棄
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def self.search(search) #User.searchと同義
    if search
      where(["name LIKE ?", "%#{search}%"]) #User.は省略
    else
      all #User.は省略
    end
  end
end
