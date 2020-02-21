class CategoryPolicy < ApplicationPolicy
  
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  def index?
    true
  end

  def show?
    true
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
