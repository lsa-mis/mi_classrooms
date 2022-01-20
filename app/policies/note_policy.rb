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
  # def toggle_visibility?
  #   user && user_in_admin_group?
  # end

  def edit?
    user.admin
  end

  def update?
    edit?
  end

  def destroy?
    user.admin
  end

end
