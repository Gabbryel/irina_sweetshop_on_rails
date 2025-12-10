class Dashboard::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @users = policy_scope(User).order(created_at: :desc).limit(200)
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update(user_params)
      redirect_to dashboard_path(anchor: 'users-admin'), notice: 'Utilizator actualizat cu succes.'
    else
      render :edit
    end
  end

  def toggle_admin
    @user = User.find(params[:id])
    authorize @user, :toggle_admin?
    # prevent toggling own admin flag accidentally
    if @user == current_user
      redirect_back fallback_location: dashboard_path(anchor: 'users-admin'), alert: 'Nu poți modifica propriul rol.'
      return
    end

    @user.update(admin: !@user.admin)
    message = @user.admin? ? 'Utilizator promovat la administrator.' : 'Permisiuni de administrator retrase.'
    redirect_back fallback_location: dashboard_path(anchor: 'users-admin'), notice: message
  end

  private

  def require_admin
    raise Pundit::NotAuthorizedError unless current_user&.admin?
  end

  def user_params
    params.require(:user).permit(:email, :admin)
  end
end
