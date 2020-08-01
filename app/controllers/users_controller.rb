class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info,
                                  :edit_basic_info_all, :update_basic_info_all]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info,
                                        :edit_basic_info_all, :update_basic_info_all]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info, :edit_basic_info_all, :update_basic_info_all]
  before_action :admin_or_correct_user, only: :show
  before_action :set_one_month, only: :show
  
  def index
    #全てのユーザー、ページネーション設定、form_withのtext_fieldで受け取ったparams[:search]の中身をself.searchに引数として渡す
    @users = User.all.paginate(page: params[:page]).search(params[:search])
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザーを作成しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の基本情報更新に失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def edit_basic_info_all
    @users = User.all
  end
  
  def update_basic_info_all
    @users = User.all
    @users.each do |user|
      unless user.update_attributes(basic_info_params)
        flash[:danger] = "基本情報の更新に失敗しました。<br>" + user.errors.full_messages.join("<br>")
        render :edit_basic_info_all
      end
    end
    flash[:success] = "全ユーザーの基本情報を更新しました。"
    redirect_to users_url
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end
end
