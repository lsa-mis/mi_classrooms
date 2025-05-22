# == Schema Information
#
# Table name: omni_auth_services
#
#  id                  :bigint           not null, primary key
#  user_id             :bigint           not null
#  provider            :string
#  uid                 :string
#  access_token        :string
#  access_token_secret :string
#  refresh_token       :string
#  expires_at          :datetime
#  auth                :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

# Handles OAuth authentication services for different providers
class OmniAuthService < ApplicationRecord
  belongs_to :user

  %w[saml].each do |provider|
    scope provider, -> { where(provider:) }
  end

  def client
    send("#{provider}_client")
  end

  def expired?
    expires_at? && expires_at <= Time.zone.now
  end

  def access_token
    send("#{provider}_refresh_token!", super) if expired?
    super
  end

  def google_oauth2_client; end
end
