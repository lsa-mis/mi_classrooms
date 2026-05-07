require "rails_helper"

RSpec.describe AnnouncementPolicy do
  subject(:policy) { described_class.new(user, announcement) }

  let(:announcement) { Announcement.new(location: "home_page") }

  describe "viewer access" do
    let(:user) do
      build_stubbed(:user).tap do |viewer|
        viewer.membership = ["mi-classrooms-non-admin-staging"]
        viewer.admin = false
      end
    end

    it "denies all announcement management actions" do
      expect(policy.index?).to be(false)
      expect(policy.show?).to be(false)
      expect(policy.create?).to be(false)
      expect(policy.update?).to be(false)
      expect(policy.destroy?).to be(false)
    end
  end

  describe "admin access" do
    let(:user) do
      build_stubbed(:user).tap do |admin|
        admin.membership = ["mi-classrooms-admin-staging"]
        admin.admin = true
      end
    end

    it "allows all announcement management actions" do
      expect(policy.index?).to be(true)
      expect(policy.show?).to be(true)
      expect(policy.create?).to be(true)
      expect(policy.update?).to be(true)
      expect(policy.destroy?).to be(true)
    end
  end
end
