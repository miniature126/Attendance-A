class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  #beforeフィルター
  
  #paramsハッシュからユーザー情報を取得
  def set_user
    @user = User.find(params[:id])
  end

  #ログイン済みユーザーか確認
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
  
  #アクセスしたユーザーが現在ログインしているユーザーか確認
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
  
  #上長ユーザーかどうか判定する
  def superior_user
    redirect_to root_url unless current_user.superior?
  end
  
  #システム管理権限所有かどうか判定
  def admin_user
    redirect_to root_url unless current_user.admin?
  end
  
  #ページ出力前に１ヶ月分のデータの存在を確認・セットする
  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    #ユーザーに紐付く１ヶ月分のレコードを検索し取得
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    #対象の月の日数とユーザーに紐付く１ヶ月分のレコードの日数が一致するか否か
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do #トランザクションを開始
        #繰り返し処理により１ヶ月分の勤怠データを生成
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
    
  rescue ActiveRecord::RecordInvalid #トランザクションによるエラー分岐
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
  
    #@userが現在ログインしているユーザー、もしくは管理者権限を持ったユーザーかどうかを確認
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "権限がありません。"
        redirect_to root_url
      end
    end
    
    #@userが現在ログインしているユーザー、もしくは上長ユーザーかどうかを確認
    def superior_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.superior?
        flash[:danger] = "アクセスできません。"
        redirect_to root_url
      end
    end
end
