class ApplicationController < ActionController::Base

  include Pagy::Backend
  before_action :store_user_location!, if: :storable_location?
  before_action :create_feedback

  private

  def sign_up_params
    params.require(:user).permit(:uniqname, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:uniqname, :email, :password, :password_confirmation, :current_password)
  end


  def user_not_authorized
    flash[:alert] = "Please sign in to perform this action."
    redirect_back(fallback_location: :user_google_oauth2_omniauth_authorize)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end


  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  def create_feedback
    @feedback = Feedback.new
  end
end
