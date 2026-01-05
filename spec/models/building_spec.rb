require 'rails_helper'

RSpec.describe Building, type: :model do
  describe 'creating a building' do
    it 'can be created with required attributes' do
      building = Building.create!(bldrecnbr: 1234567, name: 'Angell Hall')
      expect(building).to be_persisted
      expect(building.name).to eq('Angell Hall')
    end
  end

  describe 'rooms relationship' do
    it 'can have rooms' do
      building = create(:building, bldrecnbr: 2000001, zip: '48109')
      create(:room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 5000001,
        room_number: '101'
      )
      create(:room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 5000002,
        room_number: '102'
      )

      expect(building.rooms.count).to eq(2)
      expect(building.rooms.map(&:room_number)).to include('101', '102')
    end
  end

  describe 'floors relationship' do
    it 'can have floor plans' do
      building = create(:building, bldrecnbr: 2000001, zip: '48109')
      floor = Floor.new(building_bldrecnbr: building.bldrecnbr, floor: '1')
      floor.floor_plan.attach(
        io: StringIO.new("fake image"),
        filename: 'floor1.png',
        content_type: 'image/png'
      )
      floor.save!

      expect(building.floors.count).to eq(1)
      expect(building.floors.first.floor).to eq('1')
    end
  end

  describe 'notes relationship' do
    it 'can have notes attached' do
      building = create(:building, bldrecnbr: 2000001, zip: '48109')
      user = create(:user)
      note = Note.new(noteable: building, user: user, alert: true)
      note.body = 'Building under construction'
      note.save!

      expect(building.notes.count).to eq(1)
      expect(building.notes.first.body.to_plain_text).to include('construction')
    end
  end

  describe 'finding buildings by visibility' do
    let!(:visible_building) do
      create(:building,
        bldrecnbr: 2000001,
        name: 'Visible Building',
        visible: true,
        zip: '48109'
      )
    end

    let!(:hidden_building) do
      create(:building,
        bldrecnbr: 2000002,
        name: 'Hidden Building',
        visible: false,
        zip: '48109'
      )
    end

    it 'can list hidden buildings' do
      results = Building.inactive
      expect(results).to include(hidden_building)
      expect(results).not_to include(visible_building)
    end
  end

  describe 'finding buildings by campus' do
    let!(:ann_arbor_48109) { create(:building, bldrecnbr: 2000001, name: 'Central Campus', zip: '48109') }
    let!(:ann_arbor_48104) { create(:building, bldrecnbr: 2000002, name: 'South Campus', zip: '48104-1234') }
    let!(:ann_arbor_48103) { create(:building, bldrecnbr: 2000003, name: 'West Side', zip: '48103') }
    let!(:dearborn) { create(:building, bldrecnbr: 2000004, name: 'Dearborn Building', zip: '48128') }
    let!(:flint) { create(:building, bldrecnbr: 2000005, name: 'Flint Building', zip: '48502') }

    it 'returns Ann Arbor campus buildings (zip codes 48103-48109)' do
      results = Building.ann_arbor_campus
      expect(results).to include(ann_arbor_48109)
      expect(results).to include(ann_arbor_48104)
      expect(results).to include(ann_arbor_48103)
      expect(results).not_to include(dearborn)
      expect(results).not_to include(flint)
    end
  end

  describe 'finding buildings with classrooms' do
    it 'returns buildings that contain classrooms' do
      building_with_classroom = create(:building, bldrecnbr: 2000007, zip: '48109')
      create(:room,
        building_bldrecnbr: building_with_classroom.bldrecnbr,
        rmrecnbr: 5000001,
        rmtyp_description: 'Classroom',
        facility_code_heprod: 'TEST101',
        instructional_seating_count: 50
      )

      building_with_office = create(:building, bldrecnbr: 2000008, zip: '48109')
      create(:room,
        building_bldrecnbr: building_with_office.bldrecnbr,
        rmrecnbr: 5000002,
        rmtyp_description: 'Office',
        facility_code_heprod: 'TEST102',
        instructional_seating_count: 1
      )

      empty_building = create(:building, bldrecnbr: 2000009, zip: '48109')

      results = Building.with_classrooms
      expect(results).to include(building_with_classroom)
      expect(results).not_to include(building_with_office)
      expect(results).not_to include(empty_building)
    end
  end

  describe 'location data' do
    it 'stores geographic coordinates' do
      building = create(:building, bldrecnbr: 3000001, latitude: 42.2808, longitude: -83.7430)
      building.reload
      expect(building.latitude).to be_within(0.0001).of(42.2808)
      expect(building.longitude).to be_within(0.0001).of(-83.7430)
    end
  end

  describe 'searching buildings' do
    let!(:angell_hall) do
      create(:building,
        bldrecnbr: 4000001,
        name: 'Angell Hall',
        nick_name: 'Angell',
        abbreviation: 'AH',
        zip: '48109'
      )
    end

    let!(:chemistry_building) do
      create(:building,
        bldrecnbr: 4000002,
        name: 'Chemistry Building',
        nick_name: 'Chem',
        abbreviation: 'CHEM',
        zip: '48109'
      )
    end

    it 'finds buildings by name' do
      results = Building.with_name('Angell Hall')
      expect(results).to include(angell_hall)
      expect(results).not_to include(chemistry_building)
    end

    it 'finds buildings by nickname' do
      results = Building.with_name('Chem')
      expect(results).to include(chemistry_building)
    end

    it 'finds buildings by abbreviation' do
      results = Building.with_name('AH')
      expect(results).to include(angell_hall)
    end

    it 'supports partial matching' do
      results = Building.with_name('Ang')
      expect(results).to include(angell_hall)
    end
  end
end
