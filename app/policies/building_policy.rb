class BuildingPolicy < ApplicationPolicy
  # include LdapableHelper
  class Scope < Scope

    def resolve
      if user && user_in_group?
        scope.all
      else
        # scope.where(visible: true)
        scope.all
      end
    end
  end

  def index?
    user.admin
  end

  def new
    false
  end

  def show?
    user.admin
  end

  def update?
    user.admin
  end
end
