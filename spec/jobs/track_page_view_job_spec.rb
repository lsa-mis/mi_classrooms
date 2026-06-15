require "rails_helper"

RSpec.describe TrackPageViewJob, type: :job do
  let(:occurred_at) { Time.current }

  let(:valid_args) do
    {
      session_token: "a" * 32,
      controller_name: "rooms",
      action_name: "index",
      path: "/rooms",
      http_status: 200,
      duration_ms: 55,
      occurred_at: occurred_at.iso8601(6)
    }
  end

  it "creates a PageView row" do
    expect { described_class.perform_now(**valid_args) }
      .to change(PageView, :count).by(1)
  end

  it "persists the correct attributes" do
    described_class.perform_now(**valid_args)
    pv = PageView.last
    expect(pv.controller_name).to eq("rooms")
    expect(pv.action_name).to eq("index")
    expect(pv.http_status).to eq(200)
    expect(pv.duration_ms).to eq(55)
  end

  it "accepts an optional user_id" do
    user = create(:user)
    described_class.perform_now(**valid_args.merge(user_id: user.id))
    expect(PageView.last.user_id).to eq(user.id)
  end

  it "runs on the analytics queue" do
    expect(described_class.new.queue_name).to eq("analytics")
  end
end
