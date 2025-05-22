class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :saml
  before_action :store_user_location!
  before_action :set_omni_auth_service, except: [:failure]
  before_action :set_user, except: [:failure]
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

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, $baseURL)
  end

  private


  def handle_auth(kind)
    if omni_auth_service.present?
      omni_auth_service.update(omni_auth_service_attrs)
    else
      user.omni_auth_services.create(omni_auth_service_attrs)
    end

    sign_in_and_redirect user, event: :authentication
    $baseURL = ''
    set_flash_message :notice, :success, kind: kind
  end

  def user_is_stale?
    return unless user_signed_in?
    current_user.last_sign_in_at < 15.minutes.ago
  end
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
  @omni_auth_service = OmniAuthService.where(provider: auth.provider, uid: auth.uid).first
end

def set_user
  if user_signed_in?
    @user = current_user
  elsif omni_auth_service.present?
    @user = omni_auth_service.user
  elsif auth.present? && auth.info.present() && auth.info.email.present()
    # Use atomic find-or-create operation
    @user = User.from_omniauth(auth)

    # If there were validation errors preventing user creation
    unless @user.persisted?
      redirect_to new_user_session_path, alert: "We couldn't create an account. Please try again or contact support."
      return
    end
  else
    redirect_to new_user_session_path, alert: "Authentication failed."
    return
  end

  if @user
    admin = false
    membership = []
    access_groups = ['mi-classrooms-admin-staging', 'mi-classrooms-non-admin-staging']
    if Rails.env.production?
      access_groups = ['mi-classrooms-admin']
    end
    access_groups.each do |group|
      if  LdapLookup.is_member_of_group?(@user.uniqname, group)
        membership.append(group)
      end
    end
    if Rails.env.production? && membership.include?('mi-classrooms-admin')
      admin = true
    end
    if Rails.env.staging? && membership.include?('mi-classrooms-admin-staging')
      admin = true
    end
    if Rails.env.development? && membership.include?('mi-classrooms-admin-staging')
      admin = true
    end

    session[:user_memberships] = membership
    session[:user_admin] = admin
    session[:user_email] = @user.email
  end
end

def omni_auth_service_attrs
  return {} unless auth.present? && auth.credentials.present?

  expires_at = auth.credentials.expires_at.present? ? Time.at(auth.credentials.expires_at) : nil
  {
    provider: auth.provider,
    uid: auth.uid,
    expires_at: expires_at,
    access_token: auth.credentials.token,
    access_token_secret: auth.credentials.secret,
  }
end

def get_uniqname(email)
  email.split("@").first
end
