class ClassroomPolicy < ApplicationPolicy
  # To handle redirects from legacy classroom links

  def index?
    true
  end

  def show?
    true
  end

end
