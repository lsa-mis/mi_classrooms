# frozen_string_literal: true

# Handles OAuth and SAML authentication callbacks for user sign-in
# standard:disable Style/StringLiterals, Style/GlobalVars, Style/RedundantBegin
# standard:disableStyle/TrailingCommaInHashLiteral
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :saml
  before_action :store_user_location!
  before_action :set_omni_auth_service, except: [:failure]
  before_action :set_user, except: [:failure]
  attr_reader :omni_auth_service, :user, :service

  def google_oauth2
    handle_auth 'Google'
  end

  def saml
    handle_auth 'Saml'
  end

  def failure
    message = params[:message] || 'Authentication failed.'
    redirect_to root_path, alert: message
  end

  private

  def store_user_location!
    store_location_for(:user, $baseURL)
  end

  def handle_auth(kind)
    attrs = omni_auth_service_attrs

    if omni_auth_service.present?
      omni_auth_service.update(attrs)
    else
      user.omni_auth_services.create(attrs)
    end

    sign_in_and_redirect user, event: :authentication
    $baseURL = ''
    set_flash_message :notice, :success, kind:
  end

  def auth
    request.env['omniauth.auth']
  end

  def set_omni_auth_service
    return unless auth.present?

    @omni_auth_service = OmniAuthService.where(provider: auth.provider, uid: auth.uid).first
  end

  def set_user
    @user = determine_user
    return unless @user

    membership = fetch_user_memberships
    return unless membership # fetch_user_memberships handles redirects on error

    admin = determine_admin_status(membership)
    set_user_session(membership, admin)
  end

  def determine_user
    return current_user if user_signed_in?
    return omni_auth_service.user if omni_auth_service.present?
    return create_user_from_auth if auth_valid?

    redirect_to new_user_session_path, alert: "Authentication failed."
    nil
  end

  def auth_valid?
    auth.present? && auth.info.present? && auth.info.email.present?
  end

  def create_user_from_auth
    user = User.from_omniauth(auth)

    unless user.persisted?
      redirect_to new_user_session_path, alert: "We couldn't create an account. Please try again or contact support."
      return nil
    end

    user
  end

  def fetch_user_memberships
    membership = []

    access_groups_for_environment.each do |group|
      begin
        membership << group if LdapLookup.is_member_of_group?(@user.uniqname, group)
      rescue Net::LDAP::Error => e
        handle_ldap_error(e)
        return nil
      end
    end

    membership
  end

  def access_groups_for_environment
    case Rails.env.to_s
    when 'production'
      ['mi-classrooms-admin']
    else
      ['mi-classrooms-admin-staging', 'mi-classrooms-non-admin-staging']
    end
  end

  def handle_ldap_error(error)
    Rails.logger.error("LDAP error during group membership check: #{error.message}")
    flash[:alert] = "Authentication failed due to a temporary issue. Please try again later or contact support."
    redirect_to new_user_session_path
  end

  def determine_admin_status(membership)
    admin_groups = {
      'production' => 'mi-classrooms-admin',
      'staging' => 'mi-classrooms-admin-staging',
      'development' => 'mi-classrooms-admin-staging'
    }

    admin_group = admin_groups[Rails.env.to_s]
    admin_group && membership.include?(admin_group)
  end

  def set_user_session(membership, admin)
    session[:user_memberships] = membership
    session[:user_admin] = admin
    session[:user_email] = @user.email
  end

  def omni_auth_service_attrs
    return {} unless auth.present?

    # For SAML, we don't have credentials but we do have provider and uid
    {
      provider: auth.provider,
      uid: auth.info.email || auth.info.uid,
      expires_at: nil,
      access_token: nil,
      access_token_secret: nil
    }
  end

  def get_uniqname(email)
    email.split('@').first
  end
end
# standard:enable Style/StringLiterals, Style/GlobalVars, Style/RedundantBegin
# standard:enable Style/TrailingCommaInHashLiteral
