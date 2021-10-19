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
    true
  end

  def show?
    true
  end

  def update?
    if user
      true
    end
  end
end

private

def moni_pat
  ['dschmura', 'rsmoke']
end

def user_in_group?
  # user.authorized_groups.includes?
  # true
  if user.email.include?("moni_pat")
    true
  else
    false
  end
end