require "rails_helper"

RSpec.describe BuildingPolicy do
  subject(:policy) { described_class.new(user, building) }

  let(:building) { build_stubbed(:building) }

  describe "viewer access" do
    let(:user) do
      build_stubbed(:user).tap do |viewer|
        viewer.membership = ["mi-classrooms-non-admin-staging"]
        viewer.admin = false
      end
    end

    it "denies management actions" do
      expect(policy.index?).to be(false)
      expect(policy.show?).to be(false)
      expect(policy.update?).to be(false)
    end
  end

  describe "admin access" do
    let(:user) do
      build_stubbed(:user).tap do |admin|
        admin.membership = ["mi-classrooms-admin-staging"]
        admin.admin = true
      end
    end

    it "allows management actions" do
      expect(policy.index?).to be(true)
      expect(policy.show?).to be(true)
      expect(policy.update?).to be(true)
    end
  end
end
