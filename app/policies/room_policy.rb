class RoomPolicy < ApplicationPolicy
  # class Scope < Scope
  #   def resolve
  #     if user.admin?
  #       scope.all
  #     else
  #       raise Pundit::NotAuthorizedError, 'not allowed to view this action'
  #     end
  #   end
  # end
  
  def index?
    user && user_in_non_admin_group?
  end

  def show?
    user && user_in_non_admin_group?
  end

  def toggle_visibility?
    user && user_in_admin_group?
  end

  def edit?
    user && user_in_admin_group?
  end

  def update?
    edit?
  end
end

# private

# def bespoke_team
#   ['dschmura', 'rsmoke', 'brita', 'anantas', 'jjsantos', 'mlaitan', 'prbelden', 'mdressle']
# end

# def user_in_group?
#   # user.authorized_groups.includes?
#   # true
#   if bespoke_team.include?(user.uniqname)
#     true
#   else
#     false
#   end
# end