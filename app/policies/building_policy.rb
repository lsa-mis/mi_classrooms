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
    if user 
      true
    end
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

def bespoke_team
  ['dschmura', 'rsmoke', 'brita', 'anantas', 'jjsantos', 'mlaitan', 'prbelden', 'mdressle']
end

def user_in_group?
  # user.authorized_groups.includes?
  # true
  if bespoke_team.include?(user.uniqname)
    true
  else
    false
  end
end