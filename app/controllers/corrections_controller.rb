class CorrectionsController < ApplicationController
  before_action :set_user, only: :attendance_log

  def attendance_log
    @attendances = @user.attendances.where(log_flag: true)
  end
end
