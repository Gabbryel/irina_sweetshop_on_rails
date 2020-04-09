class DeviseUsersController < ApplicationController
  
  def index
    @devise_users = policy_scope(User)
  end

  def show
    @devise_user = current_user
    authorize @devise_user
  end
end
