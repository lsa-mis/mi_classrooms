require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'associations' do
    it { should belong_to(:building).with_foreign_key('building_bldrecnbr') }
    it { should belong_to(:campus_record).optional }
    it { should have_many(:room_characteristics).with_foreign_key('rmrecnbr').dependent(:destroy) }
    it { should have_one(:room_contact).with_foreign_key('rmrecnbr').dependent(:destroy) }
    it { should have_many(:notes) }
    it { should have_one_attached(:room_panorama) }
    it { should have_one_attached(:room_image) }
    it { should have_one_attached(:room_layout) }
    it { should have_one_attached(:gallery_image1) }
    it { should have_one_attached(:gallery_image2) }
    it { should have_one_attached(:gallery_image3) }
    it { should have_one_attached(:gallery_image4) }
    it { should have_one_attached(:gallery_image5) }
  end

  describe 'validations' do
    let(:room) { build(:room) }

    context 'with building association' do
      it 'is valid with a building' do
        expect(room).to be_valid
      end

      it 'is not valid without a building' do
        room.building = nil
        room.building_bldrecnbr = nil
        expect(room).not_to be_valid
        expect(room.errors[:building]).to include("must exist")
      end
    end

    context 'with room images' do
      it 'validates acceptable image size' do
        large_file = double('file', 
          attached?: true, 
          blob: double('blob', byte_size: 11.megabytes),
          content_type: 'image/jpeg',
          name: 'room_image'
        )
        allow(room).to receive(:room_image).and_return(large_file)
        
        room.valid?
        expect(room.errors[:room_image]).to include('is too big')
      end

      it 'validates acceptable image type' do
        invalid_file = double('file',
          attached?: true,
          blob: double('blob', byte_size: 1.megabyte),
          content_type: 'text/plain',
          name: 'room_image'
        )
        allow(room).to receive(:room_image).and_return(invalid_file)
        
        room.valid?
        expect(room.errors[:room_image]).to include('incorrect file type')
      end

      it 'accepts valid image types' do
        valid_file = double('file',
          attached?: true,
          blob: double('blob', byte_size: 1.megabyte),
          content_type: 'image/webp',
          name: 'room_image'
        )
        allow(room).to receive(:room_image).and_return(valid_file)
        
        expect(room).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:classroom) { create(:room, :classroom, instructional_seating_count: 50) }
    let!(:inactive_classroom) { create(:room, :classroom, :inactive, instructional_seating_count: 30) }
    let!(:lab) { create(:room, :lab) }
    let!(:office) { create(:room, rmtyp_description: 'Office', instructional_seating_count: 1) }

    describe '.classrooms' do
      it 'returns only classrooms with seating > 1' do
        expect(Room.classrooms).to include(classroom)
        expect(Room.classrooms).not_to include(office)
        expect(Room.classrooms).not_to include(lab)
      end

      it 'excludes rooms without facility codes' do
        classroom_without_facility = create(:room, rmtyp_description: 'Classroom', facility_code_heprod: nil)
        expect(Room.classrooms).not_to include(classroom_without_facility)
      end
    end

    describe '.classrooms_inactive' do
      it 'returns only inactive classrooms' do
        expect(Room.classrooms_inactive).to include(inactive_classroom)
        expect(Room.classrooms_inactive).not_to include(classroom)
      end
    end

    describe '.classroom_labs' do
      it 'returns only class laboratories' do
        expect(Room.classroom_labs).to include(lab)
        expect(Room.classroom_labs).not_to include(classroom)
      end
    end

    describe '.classrooms_including_labs' do
      it 'returns both classrooms and labs' do
        expect(Room.classrooms_including_labs).to include(classroom)
        expect(Room.classrooms_including_labs).to include(lab)
        expect(Room.classrooms_including_labs).not_to include(office)
      end
    end
  end

  describe 'search functionality' do
    let!(:building) { create(:building, name: 'Engineering Building', abbreviation: 'ENGR') }
    let!(:room1) { create(:room, building: building, characteristics: ['WiFi', 'Projector']) }
    let!(:room2) { create(:room, building: building, characteristics: ['Computer']) }

    describe '.with_building_name' do
      it 'finds rooms by building name' do
        results = Room.with_building_name('Engineering')
        expect(results).to include(room1, room2)
      end

      it 'finds rooms by building abbreviation' do
        results = Room.with_building_name('ENGR')
        expect(results).to include(room1, room2)
      end
    end

    describe '.with_all_characteristics' do
      it 'finds rooms with specific characteristics' do
        results = Room.with_all_characteristics(['WiFi'])
        expect(results).to include(room1)
        expect(results).not_to include(room2)
      end
    end
  end

  describe '#display_name' do
    let(:room) { build(:room, facility_code_heprod: 'ENG101') }

    context 'with nickname' do
      it 'includes nickname in display name' do
        room.nickname = 'Lab A'
        expect(room.display_name).to eq('ENG101 - Lab A')
      end
    end

    context 'without nickname' do
      it 'returns just facility code' do
        room.nickname = nil
        expect(room.display_name).to eq('ENG101')
      end
    end
  end

  describe 'callbacks' do
    describe 'after_commit :generate_thumbnails' do
      let(:room) { create(:room) }

      context 'when room_image is attached' do
        before do
          allow(room).to receive(:room_image_attached?).and_return(true)
          allow(room).to receive_message_chain(:room_image, :attached?).and_return(true)
          allow(room).to receive_message_chain(:room_image, :blob, :present?).and_return(true)
        end

        it 'enqueues ProcessThumbnailJob' do
          expect(ProcessThumbnailJob).to receive(:perform_later).with(room)
          room.send(:generate_thumbnails)
        end
      end

      context 'when room_image is not attached' do
        before do
          allow(room).to receive(:room_image_attached?).and_return(false)
        end

        it 'does not enqueue job' do
          expect(ProcessThumbnailJob).not_to receive(:perform_later)
          room.send(:generate_thumbnails)
        end
      end
    end
  end

  describe '#acceptable_image' do
    let(:room) { build(:room) }

    context 'when no images are attached' do
      before do
        allow(room).to receive(:room_panorama).and_return(double(attached?: false))
        allow(room).to receive(:room_image).and_return(double(attached?: false))
        allow(room).to receive(:room_layout).and_return(double(attached?: false))
        allow(room).to receive(:gallery_image1).and_return(double(attached?: false))
        allow(room).to receive(:gallery_image2).and_return(double(attached?: false))
        allow(room).to receive(:gallery_image3).and_return(double(attached?: false))
        allow(room).to receive(:gallery_image4).and_return(double(attached?: false))
        allow(room).to receive(:gallery_image5).and_return(double(attached?: false))
      end

      it 'does not add errors' do
        room.send(:acceptable_image)
        expect(room.errors).to be_empty
      end
    end
  end

  describe 'primary key' do
    it 'uses rmrecnbr as primary key' do
      expect(Room.primary_key).to eq('rmrecnbr')
    end
  end

  describe 'factory' do
    it 'creates valid room' do
      room = build(:room)
      expect(room).to be_valid
    end

    it 'creates room with unique rmrecnbr' do
      room1 = create(:room)
      room2 = create(:room)
      expect(room1.rmrecnbr).not_to eq(room2.rmrecnbr)
    end

    context 'with traits' do
      it 'creates classroom with correct attributes' do
        room = create(:room, :classroom)
        expect(room.rmtyp_description).to eq('Classroom')
        expect(room.visible).to be true
      end

      it 'creates inactive room' do
        room = create(:room, :inactive)
        expect(room.visible).to be false
      end

      it 'creates lab room' do
        room = create(:room, :lab)
        expect(room.rmtyp_description).to eq('Class Laboratory')
      end
    end
  end
end