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
    @non_admin_group = 'mi-classrooms-non-admin'
    user.membership.include?(@non_admin_group)
  end
  
  def user_in_admin_group?
    @admin_group = 'mi-classrooms-admin'
    user.membership.include?(@admin_group)
  end

  # class Scope
  #   def initialize(user, scope)
  #     @user = user
  #     @scope = scope
  #   end

  #   def resolve
  #     scope.all
  #   end

  #   private

  #   attr_reader :user, :scope
  # end
end
