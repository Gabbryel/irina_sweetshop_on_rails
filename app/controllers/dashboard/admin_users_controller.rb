class Dashboard::AdminUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: %i[show edit update destroy toggle_admin]

  def index
    @sort = params[:sort].presence_in(%w[email created_at role]) || "created_at"
    @direction = params[:direction].presence_in(%w[asc desc]) || "desc"

    base_scope = policy_scope(User)

    @users =
      case @sort
      when "email"
        base_scope.order(email: @direction)
      when "role"
        # admins first, then by email
        base_scope.order(admin: :desc, email: @direction)
      else
        base_scope.order(created_at: @direction)
      end
  end

  def show
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user
    if @user.save
      redirect_to dashboard_admin_user_path(@user), notice: 'Utilizator creat cu succes.'
    else
      render :new
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to dashboard_admin_user_path(@user), notice: 'Utilizator actualizat cu succes.'
    else
      render :edit
    end
  end

  def destroy
    authorize @user
    if @user == current_user
      redirect_back fallback_location: dashboard_admin_users_path, alert: 'Nu îți poți șterge propriul cont.'
      return
    end

    @user.destroy
    redirect_to dashboard_admin_users_path, notice: 'Utilizator șters.'
  end

  def toggle_admin
    authorize @user, :toggle_admin?

    if @user == current_user
      redirect_back fallback_location: dashboard_admin_users_path, alert: 'Nu poți modifica propriul rol.'
      return
    end

    @user.update(admin: !@user.admin)
    message = @user.admin? ? 'Utilizator promovat la administrator.' : 'Permisiuni de administrator retrase.'
    redirect_back fallback_location: dashboard_admin_users_path, notice: message
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_admin
    raise Pundit::NotAuthorizedError unless current_user&.admin?
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :admin)
  end
end
