# frozen_string_literal: true

# Handles OAuth callbacks for user authentication via Google OAuth2 and SAML
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :saml
  before_action :store_user_location!
  before_action :set_omni_auth_service, except: [:failure]
  before_action :set_user, except: [:failure]
  before_action :check_existing_email, only: [:set_user]

  attr_reader :omni_auth_service, :user, :service

  def google_oauth2
    handle_auth "Google"
  end

  def saml
    handle_auth "Saml"
  end

  def failure
    message = params[:message] || "Authentication failed."
    redirect_to root_path, alert: message
  end

  private

  def store_user_location!
    store_location_for(:user, session[:return_to])
  end

  def handle_auth(kind)
    if omni_auth_service.present?
      omni_auth_service.update(omni_auth_service_attrs)
    else
      user.omni_auth_services.create(omni_auth_service_attrs)
    end

    sign_in_and_redirect user, event: :authentication
    session[:return_to] = nil
    set_flash_message :notice, :success, kind: kind
  end

  def user_is_stale?
    return false unless user_signed_in?
    current_user.last_sign_in_at < 15.minutes.ago
  end

  def update_user_mcommunity_groups
    return if user_is_stale?
    UpdateUserGroupsJob.perform_later(current_user)
  end

  def auth
    request.env["omniauth.auth"]
  end

  def set_omni_auth_service
    return unless auth.present?
    @omni_auth_service = OmniAuthService.find_by(provider: auth.provider, uid: auth.uid)
  end

  def set_user
    if user_signed_in?
      @user = current_user
    elsif omni_auth_service.present?
      @user = omni_auth_service.user
    elsif auth.present?
      @user = create_user
    else
      redirect_to new_user_session_path, alert: "Authentication failed."
      return
    end

    update_user_session if @user
  end

  def check_existing_email
    return unless auth.present? && auth.info.present? && auth.info.email.present?
    return unless User.exists?(email: auth.info.email)

    flash[:alert] = "An account with this email already exists. Please sign in with that account before connecting your #{auth.provider.titleize} account."
    redirect_to new_user_session_path
  end

  def update_user_session
    membership = check_user_memberships
    admin = determine_admin_status(membership)

    session[:user_memberships] = membership
    session[:user_admin] = admin
    session[:user_email] = @user.email
  end

  def check_user_memberships
    access_groups = Rails.env.production? ? ['mi-classrooms-admin'] : ['mi-classrooms-admin-staging', 'mi-classrooms-non-admin-staging']

    access_groups.select do |group|
      LdapLookup.is_member_of_group?(@user.uniqname, group)
    end
  end

  def determine_admin_status(membership)
    if Rails.env.production?
      membership.include?('mi-classrooms-admin')
    else
      membership.include?('mi-classrooms-admin-staging')
    end
  end

  def omni_auth_service_attrs
    return {} unless auth.present? && auth.credentials.present?

    {
      provider: auth.provider,
      uid: auth.uid,
      expires_at: auth.credentials.expires_at.present? ? Time.at(auth.credentials.expires_at) : nil,
      access_token: auth.credentials.token,
      access_token_secret: auth.credentials.secret
    }
  end

  def get_uniqname(email)
    email.split("@").first
  end

  def create_user
    return nil unless auth.present? && auth.info.present? && auth.info.email.present?

    User.create!(
      email: auth.info.email,
      uniqname: get_uniqname(auth.info.email),
      uid: auth.info.uid,
      principal_name: auth.info.principal_name,
      display_name: auth.info.name,
      person_affiliation: auth.info.person_affiliation,
      password: Devise.friendly_token[0, 20]
    )
  end
end
