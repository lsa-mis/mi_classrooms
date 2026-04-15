class Users::TestSessionsController < ApplicationController
  skip_after_action :verify_authorized
  before_action :ensure_test_login_enabled!

  def show
    user = User.find_or_initialize_by(email: test_login_email)
    if user.new_record?
      user.password = Devise.friendly_token[0, 20]
      user.save!
    end

    sign_in(:user, user)
    set_test_memberships!
    redirect_to root_path, notice: "Signed in with test login for #{user.email}."
  end

  private

  def ensure_test_login_enabled!
    raise ActionController::RoutingError, "Not Found" if Rails.env.production?

    return if secure_test_login_enabled?

    raise ActionController::RoutingError, "Not Found"
  end

  def secure_test_login_enabled?
    configured = ActiveModel::Type::Boolean.new.cast(ENV["ENABLE_TEST_LOGIN"])
    return false unless configured

    expected_token = ENV["TEST_LOGIN_TOKEN"].to_s
    return false if expected_token.blank?

    ActiveSupport::SecurityUtils.secure_compare(params[:token].to_s, expected_token)
  end

  def test_login_email
    ENV["TEST_LOGIN_EMAIL"].presence || "test.login@umich.edu"
  end

  def set_test_memberships!
    memberships = ENV["TEST_LOGIN_GROUPS"].to_s.split(",").map(&:strip).reject(&:blank?)
    memberships = default_memberships if memberships.empty?

    session[:user_memberships] = memberships
    session[:user_admin] = memberships.include?(admin_group_for_env)
    session[:user_email] = test_login_email
  end

  def default_memberships
    [admin_group_for_env]
  end

  def admin_group_for_env
    Rails.env.production? ? "mi-classrooms-admin" : "mi-classrooms-admin-staging"
  end
end
