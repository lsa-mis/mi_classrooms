class FloorPolicy < ApplicationPolicy

  def new?
    user.admin
  end

  def create?
    user.admin
  end

  def show?
    user.admin
  end

  def update?
    user.admin
  end
end
