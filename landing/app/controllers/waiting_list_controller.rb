class WaitingListController < ApplicationController
  def create
    @waiting_list_user = WaitingListUser.new(permitted_params)

    if @waiting_list_user.save
      flash[:notice] = 'Thanks! You have been added to the waiting list.'
    else
      flash[:alert] = 'There was a problem adding you to the waiting list.'
    end
  end

  private

  def permitted_params
    params.require(:waiting_list_user).permit(:email)
  end
end