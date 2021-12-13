class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_in_group
  before_action :set_membership
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index

  private

  def user_not_authorized
    flash[:alert] = "Please sign in to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def user_not_in_group
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to about_path
  end

  def set_membership
    if user_signed_in?
      current_user.membership = session[:user_memberships]
      current_user.admin = session[:user_admin]
    else
      new_user_session_path
    end
    
  end

end
