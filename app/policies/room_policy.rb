class RoomPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        raise Pundit::NotAuthorizedError, 'not allowed to view this action'
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