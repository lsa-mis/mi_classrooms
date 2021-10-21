class RoomPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user && user_in_group?
        scope.all
      else
        raise Pundit::NotAuthorizedError, 'not allowed to view this action'
      end
    end
  end
  
  def index?
    user && user_in_group?
  end

  def show?
    user && user_in_group?
  end

end

private

def bespoke_team
  ['dschmura', 'rsmoke', 'anantas', 'jjsantos', 'mlaitan', 'prbelden', 'mdressle']
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