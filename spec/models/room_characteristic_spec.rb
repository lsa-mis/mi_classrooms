require 'rails_helper'

RSpec.describe RoomCharacteristic, type: :model do
  describe 'associations' do
    it { should belong_to(:room).with_foreign_key('rmrecnbr') }
  end

  describe 'validations' do
    subject { build(:room_characteristic) }
    it { should validate_presence_of(:rmrecnbr) }
    it { should validate_uniqueness_of(:chrstc).scoped_to(:rmrecnbr).with_message('- combination of chrstc and rmrecnbr should be unique') }
  end

  describe 'scopes' do
    let!(:room1) { create(:room) }
    let!(:room2) { create(:room) }
    let!(:room3) { create(:room) }

    before do
      create(:room_characteristic, room: room1, chrstc_descrshort: 'BluRay', chrstc: 2001)
      create(:room_characteristic, room: room1, chrstc_descrshort: 'WiFi')
      create(:room_characteristic, room: room2, chrstc_descrshort: 'BluRay')
      create(:room_characteristic, room: room2, chrstc_descrshort: 'ProjDigit')
      create(:room_characteristic, room: room3, chrstc_descrshort: 'Chkbrd')
    end

    describe '.matches_params' do
      it 'returns room record numbers with matching characteristics' do
        results = RoomCharacteristic.matches_params(['BluRay'])
        expect(results).to contain_exactly(room1.rmrecnbr, room2.rmrecnbr)
      end
    end

    describe '.has_all_characteristics' do
      it 'returns rooms that have all specified characteristics' do
        results = RoomCharacteristic.has_all_characteristics(['BluRay'])
        expect(results).to contain_exactly(room1.rmrecnbr, room2.rmrecnbr)
      end

      it 'returns only rooms with all characteristics when multiple specified' do
        create(:room_characteristic, room: room1, chrstc_descrshort: 'ProjDigit', chrstc: 2002)
        results = RoomCharacteristic.has_all_characteristics(['BluRay', 'ProjDigit'])
        expect(results).to contain_exactly(room1.rmrecnbr, room2.rmrecnbr)
      end

      it 'returns empty array when no rooms have all characteristics' do
        results = RoomCharacteristic.has_all_characteristics(['NonExistent'])
        expect(results).to be_empty
      end
    end

    describe '.has_any_characteristics' do
      it 'returns rooms with any of the specified characteristics' do
        results = RoomCharacteristic.has_any_characteristics(['BluRay', 'Chkbrd'])
        expect(results).to contain_exactly(room1.rmrecnbr, room2.rmrecnbr, room3.rmrecnbr)
      end
    end

    # Test specific characteristic scopes
    describe 'characteristic-specific scopes' do
      before do
        create(:room_characteristic, room: room1, chrstc_descrshort: 'BluRay', chrstc: 3001)
        create(:room_characteristic, room: room1, chrstc_descrshort: 'Chkbrd>25', chrstc: 3002)
        create(:room_characteristic, room: room1, chrstc_descrshort: 'DocCam', chrstc: 3003)
        create(:room_characteristic, room: room1, chrstc_descrshort: 'IntrScreen', chrstc: 3004)
        create(:room_characteristic, room: room1, chrstc_descrshort: 'InstrComp', chrstc: 3005)
      end

      it '.bluray returns BluRay characteristics' do
        expect(RoomCharacteristic.bluray.pluck(:chrstc_descrshort)).to include('BluRay')
      end

      it '.chalkboard returns chalkboard characteristics' do
        expect(RoomCharacteristic.chalkboard.pluck(:chrstc_descrshort)).to include('Chkbrd>25')
      end

      it '.doccam returns document camera characteristics' do
        expect(RoomCharacteristic.doccam.pluck(:chrstc_descrshort)).to include('DocCam')
      end

      it '.interactive_screen returns interactive screen characteristics' do
        expect(RoomCharacteristic.interactive_screen.pluck(:chrstc_descrshort)).to include('IntrScreen')
      end

      it '.instructor_computer returns instructor computer characteristics' do
        expect(RoomCharacteristic.instructor_computer.pluck(:chrstc_descrshort)).to include('InstrComp')
      end
    end
  end

  describe 'feature detection methods' do
    let(:room) { create(:room) }

    describe '#feature?' do
      it 'returns self for feature amenities' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'AssistLis')
        expect(characteristic.feature?).to eq(characteristic)
      end

      it 'returns nil for non-feature amenities' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'NonFeature')
        expect(characteristic.feature?).to be_nil
      end
    end

    describe '#chalkboard_feature?' do
      it 'returns self for chalkboard characteristics' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'Chkbrd')
        expect(characteristic.chalkboard_feature?).to eq(characteristic)
      end

      it 'returns nil for non-chalkboard characteristics' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'WiFi')
        expect(characteristic.chalkboard_feature?).to be_nil
      end
    end

    describe '#teamboard_feature?' do
      it 'returns self for team board characteristics' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'TeamBoard')
        expect(characteristic.teamboard_feature?).to eq(characteristic)
      end

      it 'returns nil for non-team board characteristics' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'WiFi')
        expect(characteristic.teamboard_feature?).to be_nil
      end
    end

    describe '#teamlearning_feature?' do
      it 'returns self for team learning characteristics' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'TeamTables')
        expect(characteristic.teamlearning_feature?).to eq(characteristic)
      end
    end

    describe '#instructor_computer?' do
      it 'returns self for instructor computer characteristics' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'CompPodPC')
        expect(characteristic.instructor_computer?).to eq(characteristic)
      end
    end

    describe '#projection_feature?' do
      it 'returns self for projection characteristics' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'ProjDigit')
        expect(characteristic.projection_feature?).to eq(characteristic)
      end
    end

    describe '#whiteboard_feature?' do
      it 'returns self for whiteboard characteristics' do
        characteristic = create(:room_characteristic, room: room, chrstc_descrshort: 'Whtbrd')
        expect(characteristic.whiteboard_feature?).to eq(characteristic)
      end
    end
  end

  describe 'factory' do
    it 'creates valid room characteristic' do
      characteristic = build(:room_characteristic)
      expect(characteristic).to be_valid
    end

    it 'creates characteristic associated with room' do
      characteristic = create(:room_characteristic)
      expect(characteristic.room).to be_present
      expect(characteristic.rmrecnbr).to eq(characteristic.room.rmrecnbr)
    end
  end

  describe 'uniqueness validation' do
    let(:room) { create(:room) }
    
    it 'prevents duplicate characteristics for same room' do
      create(:room_characteristic, room: room, chrstc: 1)
      duplicate = build(:room_characteristic, room: room, chrstc: 1)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:chrstc]).to include('- combination of chrstc and rmrecnbr should be unique')
    end

    it 'allows same characteristic for different rooms' do
      room2 = create(:room)
      create(:room_characteristic, room: room, chrstc: 1)
      characteristic2 = build(:room_characteristic, room: room2, chrstc: 1)
      
      expect(characteristic2).to be_valid
    end
  end
end