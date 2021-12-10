class PagePolicy < ApplicationPolicy
  # class Scope < Scope
  #   def resolve
  #     scope.all
  #   end
  # end
  def index?
    true
  end

  def about?
    true
  end

  def room_filters_glossary?
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
