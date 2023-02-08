class ModelImagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    isUserAdm?
  end

  def show?
    isUserAdm?
  end

  def create?
    isUserAdm?
  end


  def update?
    isUserAdm?
  end

  def destroy?
    isUserAdm?
  end

  private

  def isUserAdm?
    user && user.admin
  end
end
