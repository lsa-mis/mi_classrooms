class RoomPolicy < ApplicationPolicy

  def index?
    user_in_non_admin_group?
  end

  def show?
    user_in_non_admin_group?
  end

  def floor_plan?
    user_in_non_admin_group?
  end

  def update?
    user.admin
  end

end
