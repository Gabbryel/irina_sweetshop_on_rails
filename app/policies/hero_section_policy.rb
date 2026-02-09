class HeroSectionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    isUserAdm?
  end

  def edit?
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
