class CartPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user&.admin?

      scope.none
    end
  end

  def create?
    true
  end

  def show?
    true
  end

  def dashboard_index?
    user&.admin?
  end

  def dashboard_show?
    user&.admin?
  end

  def dashboard_update?
    user&.admin?
  end

  def dashboard_destroy?
    user&.admin?
  end

  def dashboard_resend?
    user&.admin?
  end
end
