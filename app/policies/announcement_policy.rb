class AnnouncementPolicy < ApplicationPolicy
  attr_reader :user, :announcement

  def initialize(user, announcement)
    @user = user
    @announcement = announcement
  end

  def index?
    # true
    user_in_non_admin_group?
  end

  def show?
    # true
    user_in_non_admin_group?
  end  

  def edit?
    user.admin
  end

  def update?
    edit?
  end

end
