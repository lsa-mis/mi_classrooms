require 'rails_helper'

RSpec.describe Room, type: :model do

  let!(:building) { FactoryBot.create(:building) }

  it "is valid with required attributes" do
    expect(Room.new(building_bldrecnbr: building.bldrecnbr, room_number: 111)).to be_valid
  end

  it "is not valid without building_bldrecnbr attributes" do
    room = Room.create(room_number: 111)
    expect(room).to_not be_valid
    room.errors.full_messages.include?("Building must exist")

  end

end
