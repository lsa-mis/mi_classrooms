class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :saml
  before_action :set_omni_auth_service
  before_action :set_user
  attr_reader :omni_auth_service, :user, :service

  def google_oauth2
    handle_auth "Google"
  end

  def saml
    handle_auth "Saml"
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  private


  def handle_auth(kind)
    if omni_auth_service.present?
      omni_auth_service.update(omni_auth_service_attrs)
    else
      user.omni_auth_services.create(omni_auth_service_attrs)
    end

    if user_signed_in?
      flash[:notice] = "Your #{kind} account was connected."
      redirect_to edit_user_registration_path

    else
      sign_in_and_redirect user, event: :authentication
      set_flash_message :notice, :success, kind: kind
    end
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
  @omni_auth_service = OmniAuthService.where(provider: auth.provider, uid: auth.uid).first
end

def set_user
  if user_signed_in?
    @user = current_user
  elsif omni_auth_service.present?
    @user = omni_auth_service.user
  elsif User.where(email: auth.info.email).any?
    flash[:alert] = "An account with this email already exists. Please sign in with that account before connecting your #{auth.provider.titleize} account."
    redirect_to new_user_session_path

  else
    @user = create_user

  end
  puts "UPDATED RECORD!!"
  if @user
    admin = false
    membership = []
    access_groups = ['mi-classrooms-admin-staging', 'mi-classrooms-non-admin-staging']
    if Rails.env.production?
      access_groups = ['mi-classrooms-admin', 'mi-classrooms-non-admin']
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
  end
end

def omni_auth_service_attrs
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

def create_user

  @user = User.create(
    email: auth.info.email,
    uniqname: get_uniqname(auth.info.email),
    uid: auth.info.uid,
    principal_name: auth.info.principal_name,
    display_name: auth.info.name,
    person_affiliation: auth.info.person_affiliation, 
    password: Devise.friendly_token[0, 20]
  )

end
