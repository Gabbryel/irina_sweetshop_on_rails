class ModelComponentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def new?
    isUserAdm?
  end

  def create?
    new?
  end

  def destroy?
    new?
  end

  private

  def isUserAdm?
    user && user.admin
  end
end
