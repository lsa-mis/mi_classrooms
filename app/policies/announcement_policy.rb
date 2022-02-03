class AnnouncementPolicy < ApplicationPolicy
  attr_reader :user, :announcement

  def initialize(user, announcement)
    @user = user
    @announcement = announcement
  end

  def index?
    user.admin
  end

  def show?
    user.admin
  end  

  def edit?
    user.admin
  end

  def update?
    edit?
  end

  def cancel?
    edit?
  end

end
