class ApprovalsController < ApplicationController
  # before_action :set_user, only: [:edit_approval_superior_notice, :update_approval_superior_notice]
  
  def edit_approval_superior_notice
    @users = User.find(params[:user_id])
  end
  
  def update_approval_superior_notice
  end
end
