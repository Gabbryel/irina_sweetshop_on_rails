class DeliveryBlockDatePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    is_admin?
  end

  def create?
    is_admin?
  end

  def destroy?
    is_admin?
  end

  def toggle?
    is_admin?
  end

  def block_range?
    is_admin?
  end

  private

  def is_admin?
    user&.admin?
  end
end
