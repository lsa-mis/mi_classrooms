require "rails_helper"

RSpec.describe NotePolicy do
  subject(:policy) { described_class.new(user, note) }

  let(:note) { build_stubbed(:note) }

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
    end

    it "denies mutations" do
      expect(policy.create?).to be(false)
      expect(policy.update?).to be(false)
      expect(policy.destroy?).to be(false)
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
    end
  end

  describe "admin access" do
    let(:user) do
      build_stubbed(:user).tap do |admin|
        admin.membership = ["mi-classrooms-admin-staging"]
        admin.admin = true
      end
    end

    it "allows mutations" do
      expect(policy.create?).to be(true)
      expect(policy.update?).to be(true)
      expect(policy.destroy?).to be(true)
    end
  end
end
