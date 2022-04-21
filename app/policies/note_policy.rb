class NotePolicy < ApplicationPolicy
  
  def index?
    user_in_non_admin_group?
  end

  def show?
    user_in_non_admin_group?
  end

  def create?
    user.admin
  end

  def update?
    user.admin
  end

  def destroy?
    user.admin
  end

end
