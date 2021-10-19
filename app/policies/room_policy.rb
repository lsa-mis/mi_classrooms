class RoomPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def user_in_group?
      # user.authorized_groups.includes?
      if user.email.include?("dschmura")
      # if user.mcommunity_groups.include?("mi-classrooms-notify")
        true
      else
        false
      end
    end
    def resolve
      if user && user_in_group?
        scope.all
      else
        scope.where(visible: true)
        # scope.all
      end
    end
  end
  
  def index?
    false
  end

end