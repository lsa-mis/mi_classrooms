class AnalyticsDashboardPolicy < ApplicationPolicy
  def index?
    user.admin
  end

  def refresh?
    user.admin
  end
end
