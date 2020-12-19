class BasesController < ApplicationController
  def index
    @bases = Base.all
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点情報を作成しました。"
      redirect_to bases_url
    else
      redirect_to bases_url, flash: { danger: "入力エラーが#{@base.errors.full_messages.count}件ありました。<br>#{@base.errors.full_messages.join("<br>")}" }
    end
  end

  def update
  end
  
  def destroy
  end

  private
    def base_params
      params.permit(:number, :name, :attendance_type)
    end
end
