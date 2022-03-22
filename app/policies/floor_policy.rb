class FloorPolicy < ApplicationPolicy

  def create?
    user.admin
  end

  def show?
    user_in_non_admin_group?
  end

  def update?
    user.admin
  end
end
