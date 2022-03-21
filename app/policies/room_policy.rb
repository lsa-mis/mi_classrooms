class RoomPolicy < ApplicationPolicy

  def index?
    user_in_non_admin_group?
  end

  def new?
    false
  end

  def show?
    user_in_non_admin_group?
  end

  def floor_plan?
    user_in_non_admin_group?
  end

  def edit?
    user.admin
  end

  def update?
    edit?
  end

end
