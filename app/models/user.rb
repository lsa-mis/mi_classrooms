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

# Represents a user in the system with authentication and authorization capabilities
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :omniauthable, omniauth_providers: [:saml]

  attr_accessor :membership, :admin

  has_many :omni_auth_services, dependent: :destroy
  has_many :notes

  def self.from_omniauth(auth)
    find_or_create_user(auth)
  end

  def self.find_or_create_user(auth)
    where(email: auth.info.email).first_or_create do |user|
      assign_auth_attributes(user, auth)
    end
  end

  def self.assign_auth_attributes(user, auth)
    attrs = user_attributes_from_auth(auth)
    user.assign_attributes(attrs)
    user.password = Devise.friendly_token[0, 20]
  end

  def self.user_attributes_from_auth(auth)
    {
      email: auth.info.email,
      uniqname: auth.info.email.split('@').first,
      uid: auth.info.uid,
      principal_name: auth.info.principal_name,
      display_name: auth.info.name,
      person_affiliation: auth.info.person_affiliation
    }
  end
end
