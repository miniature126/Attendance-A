class CorrectionsController < ApplicationController
  before_action :set_user, only: :attendance_log

  def attendance_log
    @attendances = @user.attendances.where(change_attendances_confirmation: 3)
  end
end
