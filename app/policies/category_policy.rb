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
  
  def new?
    create?
  end

  def create?
    if user
      user.admin
    end
  end


  def update?
    if user
      user.admin
    end
  end

  def edit?
    update?
  end

  def destroy?
    if user
      user.admin
    end
  end
end
