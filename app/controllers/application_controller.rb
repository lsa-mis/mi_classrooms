class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?
  before_action :create_feedback

  private
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
