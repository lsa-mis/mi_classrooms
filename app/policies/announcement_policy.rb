class AnnouncementPolicy < ApplicationPolicy
  attr_reader :user, :announcement

  def initialize(user, announcement)
    @user = user
    @announcement = announcement
  end

  def index?
    if user && user_in_group?
      true
    end
  end

  def show?
    if user && user_in_group?
      true
    end
  end  

  def new?
    if user && user_in_group?
      true
    end
  end

  def edit?
    if user && user_in_group?
      true
    end
  end

  def update?
    edit?
  end

  def bespoke_team
    ['dschmura', 'rsmoke', 'brita', 'anantas', 'jjsantos', 'mlaitan', 'prbelden', 'mdressle']
  end
  
  def user_in_group?
    # user.authorized_groups.includes?
    # true
    if bespoke_team.include?(user.uniqname)
      true
    else
      false
    end

  end
end