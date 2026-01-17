class AuditLogPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def statistics?
    user.admin?
  end

  def export?
    user.admin?
  end
end
