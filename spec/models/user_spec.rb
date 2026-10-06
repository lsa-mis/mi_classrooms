# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  def auth_hash(email:, uid: "saml-uid-1", name: "Ada Lovelace", affiliation: "staff")
    OmniAuth::AuthHash.new(
      provider: "saml",
      uid: uid,
      info: {
        email: email,
        uid: uid,
        principal_name: email,
        name: name,
        person_affiliation: affiliation
      }
    )
  end

  describe ".user_attributes_from_auth" do
    it "maps SAML info fields onto user attributes and derives uniqname from email" do
      attrs = described_class.user_attributes_from_auth(
        auth_hash(email: "alovelace@umich.edu", uid: "uid-42", name: "Ada Lovelace", affiliation: "faculty")
      )

      expect(attrs).to eq(
        email: "alovelace@umich.edu",
        uniqname: "alovelace",
        uid: "uid-42",
        principal_name: "alovelace@umich.edu",
        display_name: "Ada Lovelace",
        person_affiliation: "faculty"
      )
    end

    it "uses only the local part of the email for uniqname" do
      attrs = described_class.user_attributes_from_auth(
        auth_hash(email: "nested.user+tag@umich.edu")
      )

      expect(attrs[:uniqname]).to eq("nested.user+tag")
    end
  end

  describe ".from_omniauth" do
    it "creates a persisted user with mapped attributes when none exists" do
      expect {
        described_class.from_omniauth(auth_hash(email: "newuser@umich.edu", uid: "new-uid", name: "New User"))
      }.to change(User, :count).by(1)

      user = User.find_by!(email: "newuser@umich.edu")
      expect(user.uniqname).to eq("newuser")
      expect(user.uid).to eq("new-uid")
      expect(user.display_name).to eq("New User")
      expect(user.principal_name).to eq("newuser@umich.edu")
      expect(user.person_affiliation).to eq("staff")
      expect(user.encrypted_password).to be_present
    end

    it "returns the existing user without creating a duplicate when email matches" do
      existing = create(:user, email: "existing@umich.edu", uniqname: "existing", display_name: "Original Name")

      expect {
        user = described_class.from_omniauth(
          auth_hash(email: "existing@umich.edu", uid: "other-uid", name: "Updated Name")
        )
        expect(user.id).to eq(existing.id)
        expect(user.display_name).to eq("Original Name")
      }.not_to change(User, :count)
    end
  end

  describe ".assign_auth_attributes" do
    it "assigns mapped attributes and a Devise-friendly password" do
      user = User.new

      described_class.assign_auth_attributes(user, auth_hash(email: "assignme@umich.edu", uid: "assign-uid"))

      expect(user.email).to eq("assignme@umich.edu")
      expect(user.uniqname).to eq("assignme")
      expect(user.uid).to eq("assign-uid")
      expect(user.password).to be_present
      expect(user.password.length).to eq(20)
    end
  end
end
