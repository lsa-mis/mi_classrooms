# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar_url             :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :omniauthable, omniauth_providers: [:saml]

  attr_accessor :membership, :admin
  has_many :omni_auth_services, dependent: :destroy
  has_many :notes

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |user|
      user.uniqname = auth.info.email.split("@").first
      user.uid = auth.info.uid
      user.principal_name = auth.info.principal_name
      user.display_name = auth.info.name
      user.person_affiliation = auth.info.person_affiliation
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
