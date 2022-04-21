class AnnouncementPolicy < ApplicationPolicy

  def index?
    user.admin
  end

  def show?
    user.admin
  end  

  def update?
    user.admin
  end

  def cancel?
    edit?
  end

end
