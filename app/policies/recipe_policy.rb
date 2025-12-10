class RecipePolicy < ApplicationPolicy
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

  def search?
    true
  end
  
  def new?
    create?
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

  def admin_recipes?
    isUserAdm?
  end

  def update_prices?
    isUserAdm?   
  end

  def bulk_update_prices?
    isUserAdm?
  end

  private 

  def isUserAdm?
    user && user.admin
  end
end
