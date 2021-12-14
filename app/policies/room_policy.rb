class RoomPolicy < ApplicationPolicy
  
  class Scope < Scope

    def resolve
      scope.all
    end
  end

  def index?
    # true
    user_in_non_admin_group?
  end

  def new?
    false
  end

  def show?
    # true
    user_in_non_admin_group?
  end

  # def toggle_visibility?
  #   user && user_in_admin_group?
  # end

  def edit?
    user.admin
  end

  def update?
    edit?
  end

end
