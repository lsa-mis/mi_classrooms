class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit
  before_action :store_user_location!, if: :storable_location?
  before_action :create_feedback
  rescue_from Pundit::NotAuthorizedError, with: :user_not_in_group
  before_action :set_membership
  after_action :verify_policy_scoped, only: :index

  private

  def sign_up_params
    params.require(:user).permit(:uniqname, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:uniqname, :email, :password, :password_confirmation, :current_password)
  end


  def user_not_authorized
    flash[:alert] = "Please sign in to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def user_not_in_group
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to root_path
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end


  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def create_feedback
    @feedback = Feedback.new
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
