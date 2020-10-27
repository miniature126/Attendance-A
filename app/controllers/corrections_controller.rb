class CorrectionsController < ApplicationController
  before_action :set_user, only: :attendance_log
  before_action :set_attendances, only: :attendance_log

  def attendance_log
    if params[:search].present?
      if params[:search]["date(1i)"].present? && params[:search]["date(2i)"].present?
        first_day = Date.new(params[:search]["date(1i)"].to_i, params[:search]["date(2i)"].to_i, params[:search]["date(3i)"].to_i)
        last_day = first_day.end_of_month
        @attendances = @attendances.where(worked_on: first_day..last_day)
      end
    end
  end

  private
    def set_attendances
      @attendances = @user.attendances.where(log_flag: true)
    end
end
