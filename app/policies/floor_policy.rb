class FloorPolicy < ApplicationPolicy

  def new?
    user.admin
  end

  def create?
    user.admin
  end

  def show?
    # user.admin
    user_in_non_admin_group?
  end

  def update?
    user.admin
  end
end
