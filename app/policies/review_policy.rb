class ReviewPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  def new?
    create?
  end

  def create?
    true
  end

  def edit?
    isUserAdm?
  end

  def update?
    edit?
  end

  def isUserAdm?
    user && user.admin
  end
end
