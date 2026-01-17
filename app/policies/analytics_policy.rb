class AnalyticsPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
