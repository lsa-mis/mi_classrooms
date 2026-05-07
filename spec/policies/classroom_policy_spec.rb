require "rails_helper"

RSpec.describe ClassroomPolicy do
  subject(:policy) { described_class.new(user, :classroom) }

  let(:user) do
    build_stubbed(:user).tap do |viewer|
      viewer.membership = ["mi-classrooms-non-admin-staging"]
      viewer.admin = false
    end
  end

  it "allows legacy classroom redirects for all authenticated users" do
    expect(policy.index?).to be(true)
    expect(policy.show?).to be(true)
  end
end
