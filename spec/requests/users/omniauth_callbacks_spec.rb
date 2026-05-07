require "rails_helper"

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  def set_auth_hash(email:, uid: email, provider: "saml")
    OmniAuth.config.mock_auth[:saml] = OmniAuth::AuthHash.new(
      provider: provider,
      uid: uid,
      info: {
        email: email,
        uid: uid,
        principal_name: email,
        name: "Test User",
        person_affiliation: "staff"
      }
    )
  end

  def stub_group_membership(admin:)
    allow(LdapLookup).to receive(:is_member_of_group?) do |uniqname, group|
      expect(uniqname).to eq("callbackuser")
      group == if admin
        "mi-classrooms-admin-staging"
      else
        "mi-classrooms-non-admin-staging"
      end
    end
  end

  describe "POST /users/auth/saml/callback" do
    before do
      OmniAuth.config.test_mode = true
    end

    after do
      OmniAuth.config.mock_auth[:saml] = nil
      OmniAuth.config.test_mode = false
    end

    it "creates a user session and membership data for admin users" do
      set_auth_hash(email: "callbackuser@umich.edu")
      stub_group_membership(admin: true)

      post user_saml_omniauth_callback_path

      expect(response).to redirect_to(root_path)
      user = User.find_by(email: "callbackuser@umich.edu")
      expect(user).to be_present
      expect(user.uniqname).to eq("callbackuser")
      expect(user.omni_auth_services.where(provider: "saml").exists?).to be(true)
    end

    it "reuses and updates an existing omni auth service" do
      user = create(:user, email: "callbackuser@umich.edu", uniqname: "callbackuser")
      service = user.omni_auth_services.create!(provider: "saml", uid: "callbackuser@umich.edu")
      set_auth_hash(email: "callbackuser@umich.edu", uid: "callbackuser@umich.edu")
      stub_group_membership(admin: false)

      post user_saml_omniauth_callback_path

      expect(response).to redirect_to(root_path)
      expect(user.omni_auth_services.count).to eq(1)
      expect(service.reload.provider).to eq("saml")
      expect(service.uid).to eq("callbackuser@umich.edu")

      get buildings_path(format: :json)
      expect(response).to redirect_to(about_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "redirects to sign in when ldap lookup fails" do
      set_auth_hash(email: "callbackuser@umich.edu")
      allow(LdapLookup).to receive(:is_member_of_group?).and_raise(Net::LDAP::Error.new("ldap down"))

      post user_saml_omniauth_callback_path

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Authentication failed due to a temporary issue. Please try again later or contact support.")
    end

    it "redirects to sign in when auth payload is missing email" do
      OmniAuth.config.mock_auth[:saml] = OmniAuth::AuthHash.new(provider: "saml", uid: "missing-email", info: {})

      post user_saml_omniauth_callback_path

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Authentication failed.")
    end

    it "redirects through omniauth failure handling" do
      OmniAuth.config.mock_auth[:saml] = :invalid_credentials
      post user_saml_omniauth_callback_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Authentication failed.")
    end
  end
end
