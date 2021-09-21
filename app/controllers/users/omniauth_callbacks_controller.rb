class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  before_action :set_omni_auth_service
  before_action :set_user
  # after_action :update_user_mcommunity_groups
  attr_reader :omni_auth_service, :user, :service

  def google_oauth2
    handle_auth "Google"
  end

  def facebook
    handle_auth "Facebook"
  end

  def twitter
    handle_auth "Twitter"
  end

  def github
    handle_auth "Github"
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
  # @omni_auth_service = OmniAuthService.create
end

def set_user
  if user_signed_in?
    @user = current_user
  elsif omni_auth_service.present?
    @user = omni_auth_service.user
  elsif User.where(email: auth.info.email).any?
    # 5. User is logged out and they login to a new account which doesn't match their old one
    flash[:alert] = "An account with this email already exists. Please sign in with that account before connecting your #{auth.provider.titleize} account."
    redirect_to new_user_session_path

  else
    @user = create_user

  end
    puts "UPDATED RECORD!!"
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

def create_user

  @user = User.create(
    email: auth.info.email,
    # uniqname: get_uniqname(auth.info.email),
    # name: auth.info.name,
    avatar_url: auth.info.image,
    password: Devise.friendly_token[0, 20]
  )

end

# <OmniAuth::AuthHash
# credentials=#<OmniAuth::AuthHash expires=true expires_at=1506091894 token="EAABflKwUrhQBABqzaa8vayyVVTspYhjEN4ixhFGdgxSA6XXvFmylyyA6nDzWE4lmqPT31ZAKNJrRKZBylQQysaB1VsoGVRyaPVfihnsKIcVna4WAlzZAfo3DCTc02RFjgz0LF3NlZB8io0OUeSTvL1lDGfDv5zNhQ5vJSiXphQZDZD"> extra=#<OmniAuth::AuthHash raw_info=#<OmniAuth::AuthHash email="excid3@gmail.com" id="1225015704269784" name="Chris Oliver">> info=#<OmniAuth::AuthHash::InfoHash email="excid3@gmail.com" image="http://graph.facebook.com/v2.6/1225015704269784/picture" name="Chris Oliver"> provider="facebook" uid="1225015704269784">
