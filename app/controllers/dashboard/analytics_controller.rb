class Dashboard::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  skip_after_action :verify_policy_scoped

  def index
    authorize :analytics, :index?
    @analytics = Dashboard::AnalyticsReport.new(params: params.to_unsafe_h).call
  end

  private

  def require_admin
    redirect_to root_path, alert: 'Nu ai permisiunea necesară.' unless current_user&.admin?
  end
end
