class ErrorPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def not_found?
    true
  end

  def index?
    true
  end

  def show?
    true  
  end
  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end
  
end
