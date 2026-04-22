require "rails_helper"

RSpec.describe RoomPolicy do
  subject(:policy) { described_class.new(user, room) }

  let(:building) { build_stubbed(:building) }
  let(:room) { build_stubbed(:room, building: building, building_bldrecnbr: building.bldrecnbr) }

  describe "viewer access" do
    let(:user) do
      build_stubbed(:user).tap do |viewer|
        viewer.membership = ["mi-classrooms-non-admin-staging"]
        viewer.admin = false
      end
    end

    it "allows read-only actions" do
      expect(policy.index?).to be(true)
      expect(policy.show?).to be(true)
      expect(policy.floor_plan?).to be(true)
    end

    it "denies updates" do
      expect(policy.update?).to be(false)
      expect(policy.toggle_visible?).to be(false)
    end
  end

  describe "authenticated users without a matching LDAP group" do
    let(:user) do
      build_stubbed(:user).tap do |viewer|
        viewer.membership = []
        viewer.admin = false
      end
    end

    it "denies read-only actions" do
      expect(policy.index?).to be(false)
      expect(policy.show?).to be(false)
      expect(policy.floor_plan?).to be(false)
    end
  end

  describe "admin access" do
    let(:user) do
      build_stubbed(:user).tap do |admin|
        admin.membership = ["mi-classrooms-admin-staging"]
        admin.admin = true
      end
    end

    it "allows updates" do
      expect(policy.update?).to be(true)
      expect(policy.toggle_visible?).to be(true)
    end
  end
end
