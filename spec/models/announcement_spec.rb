require 'rails_helper'

RSpec.describe Announcement, type: :model do
  describe 'associations' do
    it { should have_rich_text(:content) }
  end

  describe 'factory' do
    it 'creates valid announcement' do
      announcement = build(:announcement)
      expect(announcement).to be_valid
    end

    it 'creates announcement with location' do
      announcement = create(:announcement)
      expect(announcement.location).to be_present
    end
  end

  describe 'rich text content' do
    let(:announcement) { create(:announcement) }

    it 'can have rich text content' do
      announcement.content = "This is <strong>bold</strong> text"
      announcement.save!
      
      expect(announcement.content.to_s).to include("<strong>bold</strong>")
    end
  end
end