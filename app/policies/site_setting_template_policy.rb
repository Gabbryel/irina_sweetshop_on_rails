class SiteSettingTemplatePolicy < ApplicationPolicy
  def index?
    user&.admin
  end
  
  def create?
    user&.admin
  end
  
  def apply?
    user&.admin
  end
  
  def destroy?
    user&.admin
  end
  
  def manage?
    user&.admin
  end
  
  class Scope < Scope
    def resolve
      if user&.admin
        scope.all
      else
        scope.none
      end
    end
  end
end
