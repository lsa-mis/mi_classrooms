class PagePolicy < ApplicationPolicy
  class Scope < Scope

    def resolve
      if user && user_in_group?
        scope.all
      else
        # scope.where(visible: true)
        scope.all
      end
    end
  end
  def index?
    true
  end

  def about?
    true
  end

  def contact?
    true
  end

  def privacy?
    true
  end

  def project_status?
    true
  end
end
