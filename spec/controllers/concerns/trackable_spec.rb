# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trackable, type: :controller do
  controller(ApplicationController) do
    skip_after_action :verify_authorized

    def index
      head :ok
    end
  end

  before do
    allow(controller).to receive(:devise_controller?).and_return(false)
  end

  describe "#sanitized_request_path" do
    it "replaces numeric path segments so IDs are not stored" do
      allow(request).to receive(:path).and_return("/rooms/12345/notes/678")
      expect(controller.send(:sanitized_request_path)).to eq("/rooms/:id/notes/:id")
    end

    it "truncates very long paths" do
      allow(request).to receive(:path).and_return("/" + ("a" * 600))
      expect(controller.send(:sanitized_request_path).length).to eq(500)
    end
  end

  describe "#classify_device_type" do
    it "classifies bots, mobile, and desktop user agents" do
      allow(request).to receive(:user_agent).and_return("Googlebot/2.1")
      expect(controller.send(:classify_device_type)).to eq("bot")

      allow(request).to receive(:user_agent).and_return("iPhone Safari")
      expect(controller.send(:classify_device_type)).to eq("mobile")

      allow(request).to receive(:user_agent).and_return("Mozilla/5.0 Chrome")
      expect(controller.send(:classify_device_type)).to eq("desktop")
    end
  end

  describe "#skip_tracking?" do
    it "skips bots and non-HTML requests" do
      allow(request).to receive(:user_agent).and_return("bingbot")
      expect(controller.send(:skip_tracking?)).to be(true)

      allow(request).to receive(:user_agent).and_return("Mozilla/5.0 Chrome")
      allow(request).to receive(:format).and_return(ActiveSupport::StringInquirer.new("json"))
      expect(controller.send(:skip_tracking?)).to be(true)
    end

    it "skips infra and feedback paths" do
      allow(request).to receive(:user_agent).and_return("Mozilla/5.0 Chrome")
      allow(request).to receive(:format).and_return(ActiveSupport::StringInquirer.new("html"))
      allow(request).to receive(:path).and_return("/up")
      expect(controller.send(:skip_tracking?)).to be(true)
    end
  end

  describe "#extract_referrer_host" do
    it "returns the host for valid referrers and nil for invalid ones" do
      allow(request).to receive(:referrer).and_return("https://example.edu/rooms")
      expect(controller.send(:extract_referrer_host)).to eq("example.edu")

      allow(request).to receive(:referrer).and_return("not a uri")
      expect(controller.send(:extract_referrer_host)).to be_nil
    end
  end
end
