class RoomPolicy < ApplicationPolicy
  
  def index?
    # true
    user_in_non_admin_group?
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
