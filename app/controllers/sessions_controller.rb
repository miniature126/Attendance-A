class SessionsController < ApplicationController
  # before_action :user_logged_in?, only: [:new, :create]
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      flash[:success] = "ログインしました。"
      user.admin? ? redirect_back_or(users_url) : redirect_back_or(user)
    else 
      flash.now[:danger] = "認証に失敗しました。"
      render :new
    end
  end

  def destroy
    #ログイン中のみログアウト処理を実行する
    log_out if logged_in?
    flash[:success] = "ログアウトしました。"
    redirect_to root_url
  end
  
  #beforeフィルター
    # def user_logged_in?
    #   current_user?(@user)
    #   logged_in?
    #   flash[:info] = "すでにログイン済みです。"
    #   redirect_to root_url
    # end
end