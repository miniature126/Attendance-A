require "csv"

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info,
                                  :edit_basic_info_all, :update_basic_info_all, :csv_export_attendances]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info,
                                        :edit_basic_info_all, :update_basic_info_all]
  
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_attendances, only: :show
  before_action :set_superior_users, only: :show
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info, :edit_basic_info_all]
  before_action :superior_or_correct_user, only: :show
  before_action :set_one_month, only: [:show, :csv_export_attendances]
  
  def index
    @users = User.where.not(admin: true).paginate(page: params[:page])
  end

  def csv_import
    User.import(params[:file])
    redirect_to users_url
  end

  def show
    @approval = Approval.find_by(user_id: current_user.id, applied_month: @last_day)
    @worked_sum = @attendances.where.not(started_at: nil).count
    @approval_application_sum = Approval.where(approval_superior_confirmation: 2, applied_approval_superior: params[:id]).count
    @overwork_application_sum = Attendance.where(overwork_confirmation: 2, applied_overwork: params[:id]).count
    @attendances_application_sum = Attendance.where(change_attendances_confirmation: 2, applied_attendances_change: params[:id]).count
    @export_attendances = @user.attendances.where(started_at: @first_day..@last_day, finished_at: @first_day..@last_day)
  end

  #CSV出力処理
  def csv_export_attendances
    head :no_content
    attendances = @user.attendances.where(started_at: @first_day..@last_day, finished_at: @first_day..@last_day)
    filename = "#{@user.name}" + "_" + "#{@first_day.year}" + "年" + "#{@first_day.mon}" + "月_勤怠情報"

    csv1 = CSV.generate do |csv|
      columns = [ "worked_on", "started_at", "finished_at" ]
      csv << columns
      attendances.each do |attendance|
        csv << attendance.attributes.values_at(*columns)
      end
    end
    create_csv(filename, csv1)
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
      if current_user.admin?
        flash[:success] = "#{@user.name}の情報を更新しました。"
        redirect_to users_url
      else
        flash[:success] = "ユーザー情報を更新しました。"
        redirect_to @user
      end
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def attendance_employee_list
    @users = User.where(started_at_flag: true)
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
  end
  
  private
    #beforeフィルター
    #上長ユーザーを取得(ログインしているユーザーが上長だった場合は、そのユーザーは除く)
    def set_superior_users
      @superior = User.where(superior: true).where.not(id: @user.id)
    end
    
    def user_params
      params.require(:user).permit(:name, :email, :department, :employee_number, :uid, :password, :password_confirmation,
                                   :basic_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def basic_info_params
      params.require(:user).permit(:department, :basic_time)
    end

    #CSV出力処理
    def create_csv(filename, csv1)
      File.open("./#{filename}.csv", "w", encoding: "SJIS") do |file|
        file.write(csv1)
      end
      stat = File::stat("./#{filename}.csv")
      send_file("./#{filename}.csv", filename: "#{filename}.csv", length: stat.size)
    end
end
