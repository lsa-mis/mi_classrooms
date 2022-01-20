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
    if Rails.env.production?
      @non_admin_group = ['mi-classrooms-admin', 'mi-classrooms-non-admin']
    elsif Rails.env.staging?
      @non_admin_group = ['mi-classrooms-admin-staging', 'mi-classrooms-non-admin-staging']
    elsif Rails.env.development?
      @non_admin_group = ['mi-classrooms-admin-staging', 'mi-classrooms-non-admin-staging']
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