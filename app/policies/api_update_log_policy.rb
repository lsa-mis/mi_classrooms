class ApiUpdateLogPolicy < ApplicationPolicy
  def index?
    user.admin
  end

  def show?
    user.admin
  end
end
