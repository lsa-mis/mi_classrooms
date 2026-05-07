require "rails_helper"

RSpec.describe OmniAuthService, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "scopes" do
    it "filters saml providers" do
      user = create(:user)
      saml = user.omni_auth_services.create!(provider: "saml", uid: "saml-user")
      user.omni_auth_services.create!(provider: "google_oauth2", uid: "google-user")

      expect(described_class.saml).to include(saml)
      expect(described_class.saml.pluck(:provider).uniq).to eq(["saml"])
    end
  end

  describe "#expired?" do
    it "is true when expires_at is in the past" do
      service = described_class.new(expires_at: 1.minute.ago)

      expect(service.expired?).to be(true)
    end

    it "is false when expires_at is nil or in the future" do
      expect(described_class.new(expires_at: nil).expired?).to be(false)
      expect(described_class.new(expires_at: 1.minute.from_now).expired?).to be(false)
    end
  end

  describe "#client" do
    it "dispatches to the provider specific client method name" do
      service = described_class.new(provider: "saml")

      expect { service.client }.to raise_error(NoMethodError)
    end
  end

  describe "#access_token" do
    it "returns access token when not expired" do
      service = described_class.new(provider: "saml", access_token: "current-token", expires_at: 1.minute.from_now)

      expect(service.access_token).to eq("current-token")
    end

    it "attempts provider refresh path when expired" do
      service = described_class.new(provider: "saml", access_token: "old-token", expires_at: 1.minute.ago)

      expect { service.access_token }.to raise_error(NoMethodError)
    end
  end
end
