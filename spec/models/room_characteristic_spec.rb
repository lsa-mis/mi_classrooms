require 'rails_helper'

RSpec.describe RoomCharacteristic, type: :model do
  let!(:building) { create(:building, bldrecnbr: 1234567) }
  let!(:room) { create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 9999999) }

  describe 'creating a characteristic' do
    it 'can be attached to a room' do
      characteristic = RoomCharacteristic.create!(
        rmrecnbr: room.rmrecnbr,
        chrstc: 100,
        chrstc_descrshort: 'ProjDigit',
        chrstc_descr: 'Digital Projector'
      )
      expect(characteristic).to be_persisted
      expect(characteristic.room).to eq(room)
    end

    it 'requires a room' do
      characteristic = RoomCharacteristic.new(chrstc: 100, chrstc_descrshort: 'ProjDigit')
      expect(characteristic.save).to be false
      expect(characteristic.errors[:rmrecnbr]).to be_present
    end

    it 'prevents duplicate characteristics on the same room' do
      RoomCharacteristic.create!(rmrecnbr: room.rmrecnbr, chrstc: 100, chrstc_descrshort: 'ProjDigit')
      duplicate = RoomCharacteristic.new(rmrecnbr: room.rmrecnbr, chrstc: 100, chrstc_descrshort: 'ProjDigit')
      expect(duplicate.save).to be false
    end

    it 'allows the same characteristic type on different rooms' do
      room2 = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 8888888)
      RoomCharacteristic.create!(rmrecnbr: room.rmrecnbr, chrstc: 100, chrstc_descrshort: 'ProjDigit')
      other = RoomCharacteristic.new(rmrecnbr: room2.rmrecnbr, chrstc: 100, chrstc_descrshort: 'ProjDigit')
      expect(other.save).to be true
    end
  end

  describe 'finding rooms by equipment' do
    before do
      @projector = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 1, chrstc_descrshort: 'ProjDigit')
      @whiteboard = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 2, chrstc_descrshort: 'Whtbrd')
      @chalkboard = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 3, chrstc_descrshort: 'Chkbrd')
      @doccam = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 4, chrstc_descrshort: 'DocCam')
      @bluray = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 5, chrstc_descrshort: 'BluRay')
    end

    it 'finds rooms with digital projectors' do
      results = RoomCharacteristic.projector_digial
      expect(results).to include(@projector)
      expect(results).not_to include(@whiteboard)
    end

    it 'finds rooms with whiteboards including large ones' do
      large_whiteboard = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 6, chrstc_descrshort: 'Whtbrd>25')
      results = RoomCharacteristic.whiteboard
      expect(results).to include(@whiteboard)
      expect(results).to include(large_whiteboard)
      expect(results).not_to include(@chalkboard)
    end

    it 'finds rooms with chalkboards including large ones' do
      large_chalkboard = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 7, chrstc_descrshort: 'Chkbrd>25')
      results = RoomCharacteristic.chalkboard
      expect(results).to include(@chalkboard)
      expect(results).to include(large_chalkboard)
      expect(results).not_to include(@whiteboard)
    end

    it 'finds rooms with document cameras' do
      results = RoomCharacteristic.doccam
      expect(results).to include(@doccam)
      expect(results).not_to include(@projector)
    end

    it 'finds rooms with BluRay players' do
      bluray_dvd = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 8, chrstc_descrshort: 'BluRay/DVD')
      results = RoomCharacteristic.bluray
      expect(results).to include(@bluray)
      expect(results).to include(bluray_dvd)
    end

    it 'finds rooms with instructor computers' do
      instr_comp = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 9, chrstc_descrshort: 'InstrComp')
      comp_pod_pc = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 10, chrstc_descrshort: 'CompPodPC')
      comp_pod_mac = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 11, chrstc_descrshort: 'CompPodMac')

      results = RoomCharacteristic.instructor_computer
      expect(results).to include(instr_comp)
      expect(results).to include(comp_pod_pc)
      expect(results).to include(comp_pod_mac)
    end

    it 'finds rooms with team boards' do
      team_board = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 12, chrstc_descrshort: 'TeamBoard')
      expect(RoomCharacteristic.team_board).to include(team_board)
    end

    it 'finds rooms with team tables' do
      team_tables = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 13, chrstc_descrshort: 'TeamTables')
      expect(RoomCharacteristic.team_tables).to include(team_tables)
    end

    it 'finds rooms with lecture capture' do
      lecture_cap = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 14, chrstc_descrshort: 'LectureCap')
      expect(RoomCharacteristic.lecture_capture).to include(lecture_cap)
    end

    it 'finds rooms with video conferencing' do
      video_conf = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 15, chrstc_descrshort: 'VideoConf')
      expect(RoomCharacteristic.video_conf).to include(video_conf)
    end

    it 'finds rooms with interactive screens' do
      intr_screen = create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 16, chrstc_descrshort: 'IntrScreen')
      expect(RoomCharacteristic.interactive_screen).to include(intr_screen)
    end
  end

  describe 'filtering rooms by equipment requirements' do
    let!(:room2) { create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 7777777) }
    let!(:room3) { create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 6666666) }

    before do
      # Room 1 has projector and whiteboard
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 1, chrstc_descrshort: 'ProjDigit')
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 2, chrstc_descrshort: 'Whtbrd')

      # Room 2 has projector only
      create(:room_characteristic, rmrecnbr: room2.rmrecnbr, chrstc: 3, chrstc_descrshort: 'ProjDigit')

      # Room 3 has whiteboard and doccam
      create(:room_characteristic, rmrecnbr: room3.rmrecnbr, chrstc: 4, chrstc_descrshort: 'Whtbrd')
      create(:room_characteristic, rmrecnbr: room3.rmrecnbr, chrstc: 5, chrstc_descrshort: 'DocCam')
    end

    describe 'finding rooms with specific equipment' do
      it 'returns room IDs that have a projector' do
        results = RoomCharacteristic.matches_params(['ProjDigit'])
        expect(results).to include(room.rmrecnbr)
        expect(results).to include(room2.rmrecnbr)
        expect(results).not_to include(room3.rmrecnbr)
      end

      it 'returns room IDs that have a whiteboard' do
        results = RoomCharacteristic.matches_params(['Whtbrd'])
        expect(results).to include(room.rmrecnbr)
        expect(results).to include(room3.rmrecnbr)
        expect(results).not_to include(room2.rmrecnbr)
      end
    end

    describe 'finding rooms with ALL required equipment' do
      it 'returns only rooms having both projector AND whiteboard' do
        results = RoomCharacteristic.has_all_characteristics(['ProjDigit', 'Whtbrd'])
        expect(results).to include(room.rmrecnbr)
        expect(results).not_to include(room2.rmrecnbr) # only has projector
        expect(results).not_to include(room3.rmrecnbr) # only has whiteboard
      end

      it 'returns rooms matching single requirement' do
        results = RoomCharacteristic.has_all_characteristics(['ProjDigit'])
        expect(results).to include(room.rmrecnbr)
        expect(results).to include(room2.rmrecnbr)
      end
    end

    describe 'finding rooms with ANY of the equipment' do
      it 'returns rooms having projector OR doccam' do
        results = RoomCharacteristic.has_any_characteristics(['ProjDigit', 'DocCam'])
        expect(results).to include(room.rmrecnbr)   # has projector
        expect(results).to include(room2.rmrecnbr)  # has projector
        expect(results).to include(room3.rmrecnbr)  # has doccam
      end
    end
  end

  describe 'categorizing equipment types' do
    describe 'identifying features' do
      %w[AssistLis Blackout DocCam Ethernet EthrStud IntrScreen LectureCap VideoConf VCR].each do |equipment|
        it "recognizes #{equipment} as a feature" do
          char = build(:room_characteristic, chrstc_descrshort: equipment)
          expect(char.feature?).to eq(char)
        end
      end

      it 'does not categorize projectors as features' do
        char = build(:room_characteristic, chrstc_descrshort: 'ProjDigit')
        expect(char.feature?).to be_nil
      end
    end

    describe 'identifying chalkboards' do
      it 'recognizes standard chalkboards' do
        char = build(:room_characteristic, chrstc_descrshort: 'Chkbrd')
        expect(char.chalkboard_feature?).to eq(char)
      end

      it 'recognizes large chalkboards' do
        char = build(:room_characteristic, chrstc_descrshort: 'Chkbrd>25')
        expect(char.chalkboard_feature?).to eq(char)
      end

      it 'does not confuse whiteboards with chalkboards' do
        char = build(:room_characteristic, chrstc_descrshort: 'Whtbrd')
        expect(char.chalkboard_feature?).to be_nil
      end
    end

    describe 'identifying whiteboards' do
      it 'recognizes standard whiteboards' do
        char = build(:room_characteristic, chrstc_descrshort: 'Whtbrd')
        expect(char.whiteboard_feature?).to eq(char)
      end

      it 'recognizes large whiteboards' do
        char = build(:room_characteristic, chrstc_descrshort: 'Whtbrd>25')
        expect(char.whiteboard_feature?).to eq(char)
      end
    end

    describe 'identifying projection equipment' do
      %w[Proj16mm Proj35mm ProjD-Cin ProjDigit ProjSlide].each do |projector|
        it "recognizes #{projector} as projection equipment" do
          char = build(:room_characteristic, chrstc_descrshort: projector)
          expect(char.projection_feature?).to eq(char)
        end
      end
    end

    describe 'identifying instructor computers' do
      %w[InstrComp CompPodPC CompPodMac].each do |computer|
        it "recognizes #{computer} as an instructor computer" do
          char = build(:room_characteristic, chrstc_descrshort: computer)
          expect(char.instructor_computer?).to eq(char)
        end
      end
    end

    describe 'identifying team learning equipment' do
      %w[TeamBoard TeamTables TeamTech].each do |team_equipment|
        it "recognizes #{team_equipment} as team learning equipment" do
          char = build(:room_characteristic, chrstc_descrshort: team_equipment)
          expect(char.teamlearning_feature?).to eq(char)
        end
      end
    end
  end
end
