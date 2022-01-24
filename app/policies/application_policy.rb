# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def user_in_non_admin_group?
    @non_admin_group = ['mi-classrooms-admin-staging', 'mi-classrooms-non-admin-staging']
    if Rails.env.production?
      # When the app is open for the public return true
      # true
      @non_admin_group = ['mi-classrooms-admin', 'mi-classrooms-non-admin']
    end
    user.membership && (user.membership & @non_admin_group).any?
  end
  
end

 class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
end