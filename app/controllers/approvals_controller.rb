class ApprovalsController < ApplicationController
  # before_action :set_user, only: [:edit_approval_superior_notice, :update_approval_superior_notice]
  
  def update_approval_superior_request
    
  end
  
  def edit_approval_superior_notice
    @superior = User.find(params[:user_id])
  end
  
  def update_approval_superior_notice
  end
end
