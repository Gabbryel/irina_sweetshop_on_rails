class SiteSettingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    isUserAdm?
  end

  def manage?
    isUserAdm?
  end

  def update?
    isUserAdm?
  end

  private

  def isUserAdm?
    user && user.admin
  end
end
