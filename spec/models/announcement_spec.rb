require "rails_helper"

RSpec.describe Announcement, type: :model do
  describe "validations" do
    subject(:announcement) { described_class.new(location: "home_page") }

    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_inclusion_of(:location).in_array(described_class::LOCATIONS) }
  end

  describe "rich text content" do
    it "stores rich text body content" do
      announcement = described_class.create!(location: "about_page")
      announcement.content = "<div><strong>Important update</strong></div>"
      announcement.save!

      expect(announcement.content.to_plain_text).to eq("Important update")
    end
  end
end
