class AnalyticsDashboardPolicy < ApplicationPolicy
  def index?
    user.admin
  end
end
