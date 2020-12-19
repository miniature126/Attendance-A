class BasesController < ApplicationController
  def index
    @bases = Base.all
  end
  
  def create
    @base = Base.new(base_params)
    debugger
    if @base.save
      flash[:success] = "拠点情報を作成しました。"
      redirect_to bases_url
    else
      redirect_to bases_url, flash: { danger: "拠点情報追加をキャンセルしました。入力エラーが#{@base.errors.full_messages.count}件あります。<br>#{@base.errors.full_messages.join("。<br>")}" }
    end
  end

  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を修正しました。"
      redirect_to bases_url
    else
      redirect_to bases_url, flash: { danger: "更新をキャンセルしました。入力エラーが#{@base.errors.full_messages.count}件あります。<br>#{@base.errors.full_messages.join("。<br>")}" }
    end
  end
  
  def destroy
    
  end

  private
    def base_params
      params.require(:base).permit(:number, :name, :attendance_type)
    end
end
