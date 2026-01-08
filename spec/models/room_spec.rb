require 'rails_helper'

RSpec.describe Room, type: :model do
  let!(:building) { create(:building, bldrecnbr: 1234567, zip: '48109') }

  describe 'creating a room' do
    it 'can be created with required attributes' do
      room = Room.create!(
        rmrecnbr: 9999999,
        building_bldrecnbr: building.bldrecnbr,
        room_number: '101'
      )
      expect(room).to be_persisted
    end

    it 'requires a building' do
      room = Room.new(rmrecnbr: 9999999, room_number: '101')
      expect(room.save).to be false
      expect(room.errors[:building]).to include('must exist')
    end
  end

  describe 'building relationship' do
    it 'can access its building' do
      room = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 1000001)
      expect(room.building).to eq(building)
      expect(room.building.name).to be_present
    end
  end

  describe 'room characteristics relationship' do
    it 'can have equipment characteristics attached' do
      room = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 1000001)
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc_descrshort: 'ProjDigit')
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc_descrshort: 'Whtbrd')

      expect(room.room_characteristics.count).to eq(2)
      expect(room.room_characteristics.map(&:chrstc_descrshort)).to include('ProjDigit', 'Whtbrd')
    end

    it 'deletes characteristics when room is deleted' do
      room = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 1000001)
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc_descrshort: 'ProjDigit')

      expect { room.destroy }.to change { RoomCharacteristic.count }.by(-1)
    end
  end

  describe 'notes relationship' do
    it 'can have notes attached' do
      room = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 1000001)
      user = create(:user)
      note = Note.new(noteable: room, user: user, alert: false)
      note.body = 'Room will be renovated'
      note.save!

      expect(room.notes.count).to eq(1)
      expect(room.notes.first.body.to_plain_text).to include('renovated')
    end
  end

  describe 'finding classrooms' do
    let!(:classroom) do
      create(:room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1000001,
        rmtyp_description: 'Classroom',
        facility_code_heprod: 'GG101',
        instructional_seating_count: 50,
        visible: true
      )
    end

    let!(:hidden_classroom) do
      create(:room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1000002,
        rmtyp_description: 'Classroom',
        facility_code_heprod: 'GG102',
        instructional_seating_count: 30,
        visible: false
      )
    end

    let!(:class_lab) do
      create(:room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1000003,
        rmtyp_description: 'Class Laboratory',
        facility_code_heprod: 'GG103',
        instructional_seating_count: 25,
        visible: true
      )
    end

    let!(:office) do
      create(:room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1000004,
        rmtyp_description: 'Office',
        facility_code_heprod: 'GG104',
        instructional_seating_count: 1,
        visible: true
      )
    end

    describe 'listing all classrooms' do
      it 'includes rooms typed as Classroom with facility codes and seating for multiple people' do
        results = Room.classrooms
        expect(results).to include(classroom)
        expect(results).to include(hidden_classroom)
      end

      it 'excludes class laboratories and offices' do
        results = Room.classrooms
        expect(results).not_to include(class_lab)
        expect(results).not_to include(office)
      end

      it 'excludes rooms without facility codes' do
        no_facility = create(:room,
          building_bldrecnbr: building.bldrecnbr,
          rmrecnbr: 1000005,
          rmtyp_description: 'Classroom',
          facility_code_heprod: nil,
          instructional_seating_count: 50
        )
        expect(Room.classrooms).not_to include(no_facility)
      end

      it 'excludes single-occupancy rooms' do
        small_room = create(:room,
          building_bldrecnbr: building.bldrecnbr,
          rmrecnbr: 1000006,
          rmtyp_description: 'Classroom',
          facility_code_heprod: 'GG106',
          instructional_seating_count: 1
        )
        expect(Room.classrooms).not_to include(small_room)
      end
    end

    describe 'listing hidden classrooms' do
      it 'returns only classrooms marked as not visible' do
        results = Room.classrooms_inactive
        expect(results).to include(hidden_classroom)
        expect(results).not_to include(classroom)
      end
    end

    describe 'listing class laboratories' do
      it 'returns only rooms typed as Class Laboratory' do
        results = Room.classroom_labs
        expect(results).to include(class_lab)
        expect(results).not_to include(classroom)
        expect(results).not_to include(office)
      end
    end

    describe 'listing all instructional spaces' do
      it 'returns both classrooms and class laboratories' do
        results = Room.classrooms_including_labs
        expect(results).to include(classroom)
        expect(results).to include(hidden_classroom)
        expect(results).to include(class_lab)
        expect(results).not_to include(office)
      end
    end
  end

  describe 'display name' do
    it 'shows facility code with nickname when room has a nickname' do
      room = build(:room, facility_code_heprod: 'AH AUD A', nickname: 'Angell Hall Auditorium A')
      expect(room.display_name).to eq('AH AUD A - Angell Hall Auditorium A')
    end

    it 'shows only facility code when room has no nickname' do
      room = build(:room, facility_code_heprod: 'CHEM 1400', nickname: nil)
      expect(room.display_name).to eq('CHEM 1400')
    end

    it 'shows only facility code when nickname is blank' do
      room = build(:room, facility_code_heprod: 'MLB AUD 3', nickname: '')
      expect(room.display_name).to eq('MLB AUD 3')
    end
  end

  describe 'storing equipment characteristics' do
    it 'persists an array of characteristic codes' do
      room = create(:room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 3000001,
        characteristics: ['ProjDigit', 'Whtbrd', 'DocCam']
      )
      room.reload
      expect(room.characteristics).to eq(['ProjDigit', 'Whtbrd', 'DocCam'])
    end

    it 'stores empty array when no characteristics' do
      room = create(:room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 3000002,
        characteristics: []
      )
      room.reload
      expect(room.characteristics).to eq([])
    end
  end
end
