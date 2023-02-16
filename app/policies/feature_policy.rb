class FeaturePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def new?
    isUserAdm?
  end

  def create?
    isUserAdm?
  end

  def edit?
    isUserAdm?
  end

  def update?
    isUserAdm?
  end

  
  def destroy?
    isUserAdm?
  end

  def isUserAdm?
    user && user.admin
  end
end
