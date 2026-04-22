require "rails_helper"

RSpec.describe ActiveStorage::AttachmentPolicy do
  subject(:policy) { described_class.new(user, attachment) }

  let(:attachment) { instance_double(ActiveStorage::Attachment) }

  describe "viewer access" do
    let(:user) do
      build_stubbed(:user).tap do |viewer|
        viewer.membership = ["mi-classrooms-non-admin-staging"]
        viewer.admin = false
      end
    end

    it "denies attachment deletion" do
      expect(policy.delete_file_attachment?).to be(false)
    end
  end

  describe "admin access" do
    let(:user) do
      build_stubbed(:user).tap do |admin|
        admin.membership = ["mi-classrooms-admin-staging"]
        admin.admin = true
      end
    end

    it "allows attachment deletion" do
      expect(policy.delete_file_attachment?).to be(true)
    end
  end
end
