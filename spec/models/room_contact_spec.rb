require 'rails_helper'

RSpec.describe RoomContact, type: :model do
  describe 'associations' do
    it { should belong_to(:room).with_foreign_key('rmrecnbr') }
  end

  describe 'validations' do
    it { should validate_presence_of(:rmrecnbr) }
  end

  describe 'factory' do
    it 'creates valid room contact' do
      contact = build(:room_contact)
      expect(contact).to be_valid
    end

    it 'creates room contact associated with room' do
      contact = create(:room_contact)
      expect(contact.room).to be_present
      expect(contact.rmrecnbr).to eq(contact.room.rmrecnbr)
    end
  end
end
