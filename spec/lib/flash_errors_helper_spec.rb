require "rails_helper"

RSpec.describe FlashErrorsHelper, type: :helper do
  describe "#flash_class" do
    it "maps known severities to css classes" do
      expect(helper.flash_class(:alert)).to eq("alert-danger")
      expect(helper.flash_class(:error)).to eq("alert-error")
      expect(helper.flash_class(:notice)).to eq("alert-notice")
      expect(helper.flash_class(:success)).to eq("alert-success")
      expect(helper.flash_class(:warning)).to eq("alert-warning")
    end
  end

  describe "#severity_icon" do
    it "returns configured icons" do
      expect(helper.severity_icon(:danger)).to eq("shield-exclamation")
      expect(helper.severity_icon(:notice)).to eq("circle-check")
      expect(helper.severity_icon(:warning)).to eq("siren-on")
    end
  end
end
