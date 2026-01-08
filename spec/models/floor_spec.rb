require 'rails_helper'

RSpec.describe Floor, type: :model do
  let!(:building) { create(:building, bldrecnbr: 1234567) }

  describe 'associations' do
    it { should belong_to(:building).with_foreign_key(:building_bldrecnbr) }
  end

  describe 'validations' do
    it 'is valid with required attributes' do
      floor = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '1')
      floor.floor_plan.attach(
        io: StringIO.new("fake image content"),
        filename: 'floor_plan.png',
        content_type: 'image/png'
      )
      expect(floor).to be_valid
    end

    it 'requires a floor_plan attachment' do
      floor = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '1')
      expect(floor).not_to be_valid
      expect(floor.errors[:floor_plan]).to include("can't be blank")
    end

    describe 'uniqueness of floor within building' do
      it 'validates uniqueness of floor scoped to building' do
        floor1 = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '1')
        floor1.floor_plan.attach(
          io: StringIO.new("fake image"),
          filename: 'plan1.png',
          content_type: 'image/png'
        )
        floor1.save!

        floor2 = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '1')
        floor2.floor_plan.attach(
          io: StringIO.new("fake image"),
          filename: 'plan2.png',
          content_type: 'image/png'
        )
        expect(floor2).not_to be_valid
      end

      it 'allows same floor number in different buildings' do
        other_building = create(:building, bldrecnbr: 7654321)

        floor1 = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '1')
        floor1.floor_plan.attach(
          io: StringIO.new("fake image"),
          filename: 'plan1.png',
          content_type: 'image/png'
        )
        floor1.save!

        floor2 = Floor.new(building_bldrecnbr: other_building.bldrecnbr, floor: '1')
        floor2.floor_plan.attach(
          io: StringIO.new("fake image"),
          filename: 'plan2.png',
          content_type: 'image/png'
        )
        expect(floor2).to be_valid
      end
    end
  end

  describe 'image validation' do
    it 'accepts PNG images' do
      floor = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '1')
      floor.floor_plan.attach(
        io: StringIO.new("fake png content"),
        filename: 'floor_plan.png',
        content_type: 'image/png'
      )
      expect(floor).to be_valid
    end

    it 'accepts JPEG images' do
      floor = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '2')
      floor.floor_plan.attach(
        io: StringIO.new("fake jpeg content"),
        filename: 'floor_plan.jpg',
        content_type: 'image/jpeg'
      )
      expect(floor).to be_valid
    end

    it 'accepts PDF files' do
      floor = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '3')
      floor.floor_plan.attach(
        io: StringIO.new("fake pdf content"),
        filename: 'floor_plan.pdf',
        content_type: 'application/pdf'
      )
      expect(floor).to be_valid
    end
  end

  describe 'floor numbering' do
    it 'supports numeric floors' do
      floor = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '5')
      floor.floor_plan.attach(
        io: StringIO.new("fake image"),
        filename: 'plan.png',
        content_type: 'image/png'
      )
      expect(floor).to be_valid
      expect(floor.floor).to eq('5')
    end

    it 'supports basement floors' do
      floor = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: 'B1')
      floor.floor_plan.attach(
        io: StringIO.new("fake image"),
        filename: 'plan.png',
        content_type: 'image/png'
      )
      expect(floor).to be_valid
      expect(floor.floor).to eq('B1')
    end

    it 'supports ground floor' do
      floor = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: 'G')
      floor.floor_plan.attach(
        io: StringIO.new("fake image"),
        filename: 'plan.png',
        content_type: 'image/png'
      )
      expect(floor).to be_valid
      expect(floor.floor).to eq('G')
    end
  end
end
