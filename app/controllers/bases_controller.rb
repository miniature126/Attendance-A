class BasesController < ApplicationController
  before_action :set_base, only: [:update, :destroy]
  before_action :admin_user, only: [:index, :create, :update, :destroy]

  def index
    @bases = Base.all
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点情報を作成しました。"
      redirect_to bases_url
    else
      flash[:danger] = "拠点情報追加をキャンセルしました。入力エラーが#{@base.errors.full_messages.count}件あります。<br>・#{@base.errors.full_messages.join("。<br>・")}"
      redirect_to bases_url 
    end
  end

  def update
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を修正しました。"
      redirect_to bases_url
    else
      flash[:danger] = "修正をキャンセルしました。入力エラーが#{@base.errors.full_messages.count}件あります。<br>・#{@base.errors.full_messages.join("。<br>・")}"
      redirect_to bases_url
    end
  end
  
  def destroy
    flash[:success] = "拠点番号#{@base.number}のデータを削除しました。"
    @base.destroy
    redirect_to bases_url
  end

  private
    def base_params
      params.require(:base).permit(:number, :name, :attendance_type)
    end

    def set_base
      @base = Base.find(params[:id])
    end
end
