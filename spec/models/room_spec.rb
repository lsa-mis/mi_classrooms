require 'rails_helper'

RSpec.describe Room, type: :model do

  let!(:building) { FactoryBot.create(:building) }

  it "is valid with required attributes" do
    expect(Room.new(building_bldrecnbr: building.bldrecnbr, room_number: 111)).to be_valid
  end
end
