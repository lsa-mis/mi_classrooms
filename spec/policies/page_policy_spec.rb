require "rails_helper"

RSpec.describe PagePolicy do
  subject(:policy) { described_class.new(user, :page) }

  let(:user) do
    build_stubbed(:user).tap do |viewer|
      viewer.membership = ["mi-classrooms-non-admin-staging"]
      viewer.admin = false
    end
  end

  it "allows public page actions" do
    expect(policy.index?).to be(true)
    expect(policy.about?).to be(true)
    expect(policy.room_filters_glossary?).to be(true)
    expect(policy.contact?).to be(true)
    expect(policy.privacy?).to be(true)
    expect(policy.project_status?).to be(true)
  end
end
