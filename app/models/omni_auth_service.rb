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

class OmniAuthService < ApplicationRecord
  belongs_to :user

  %w[google_oauth2].each do |provider|
    scope provider, -> { where(provider: provider) }
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

  # def facebook_client
  #   Koala::Facebook::API.new(access_token)
  # end

  # def facebook_refresh_token!(token)
  #   new_token_info = Koala::Facebook::OAuth.new.exchange_access_token_info(token)
  #   update(access_token: new_token_info["access_token"], expires_at: Time.zone.now + new_token_info["expires_in"])
  # end

  def twitter_client
    # Twitter::REST::Client.new do |config|
    #   config.consumer_key        = Rails.application.secrets.twitter_app_id
    #   config.consumer_secret     = Rails.application.secrets.twitter_app_secret
    #   config.access_token        = access_token
    #   config.access_token_secret = access_token_secret
    # end
  end

  def google_oauth2_client
  end

  def twitter_refresh_token!(token)
  end
end
