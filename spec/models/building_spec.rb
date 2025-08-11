require 'rails_helper'

RSpec.describe Building, type: :model do
  describe 'associations' do
    it { should belong_to(:campus_record).optional }
    it { should have_many(:rooms).with_primary_key('bldrecnbr').with_foreign_key('building_bldrecnbr') }
    it { should have_many(:floors).with_primary_key('bldrecnbr').with_foreign_key('building_bldrecnbr') }
    it { should have_many(:notes) }
    it { should have_one_attached(:building_image) }
  end

  describe 'validations' do
    context 'with building image' do
      let(:building) { build(:building) }
      
      it 'validates acceptable image size' do
        large_file = double('file', 
          attached?: true, 
          blob: double('blob', byte_size: 11.megabytes),
          content_type: 'image/jpeg',
          name: 'building_image'
        )
        allow(building).to receive(:building_image).and_return(large_file)
        
        building.valid?
        expect(building.errors[:building_image]).to include('is too big')
      end

      it 'validates acceptable image type' do
        invalid_file = double('file',
          attached?: true,
          blob: double('blob', byte_size: 1.megabyte),
          content_type: 'text/plain',
          name: 'building_image'
        )
        allow(building).to receive(:building_image).and_return(invalid_file)
        
        building.valid?
        expect(building.errors[:building_image]).to include('incorrect file type')
      end

      it 'accepts valid image types' do
        valid_file = double('file',
          attached?: true,
          blob: double('blob', byte_size: 1.megabyte),
          content_type: 'image/jpeg',
          name: 'building_image'
        )
        allow(building).to receive(:building_image).and_return(valid_file)
        
        expect(building).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:visible_building) { create(:building, visible: true) }
    let!(:invisible_building) { create(:building, visible: false) }
    let!(:aa_building) { create(:building, zip: '48103') }
    let!(:non_aa_building) { create(:building, zip: '90210') }

    describe '.inactive' do
      it 'returns only invisible buildings' do
        expect(Building.inactive).to contain_exactly(invisible_building)
      end
    end

    describe '.ann_arbor_campus' do
      it 'returns buildings with Ann Arbor zip codes' do
        expect(Building.ann_arbor_campus).to include(aa_building)
        expect(Building.ann_arbor_campus).not_to include(non_aa_building)
      end
    end

    describe '.with_classrooms' do
      let!(:building_with_classroom) { create(:building) }
      let!(:building_without_classroom) { create(:building) }

      before do
        create(:room, :classroom, building: building_with_classroom)
        create(:room, rmtyp_description: 'Office', building: building_without_classroom)
      end

      it 'returns buildings that have classrooms' do
        expect(Building.with_classrooms).to include(building_with_classroom)
        expect(Building.with_classrooms).not_to include(building_without_classroom)
      end
    end
  end

  describe 'search functionality' do
    let!(:building1) { create(:building, name: 'Engineering Building', nick_name: 'Eng', abbreviation: 'ENGR') }
    let!(:building2) { create(:building, name: 'Library Building', nick_name: 'Lib', abbreviation: 'LIB') }

    describe '.with_name' do
      it 'finds buildings by name' do
        results = Building.with_name('Engineering')
        expect(results).to include(building1)
        expect(results).not_to include(building2)
      end

      it 'finds buildings by nickname' do
        results = Building.with_name('Eng')
        expect(results).to include(building1)
      end

      it 'finds buildings by abbreviation' do
        results = Building.with_name('ENGR')
        expect(results).to include(building1)
      end
    end
  end

  describe '#acceptable_image' do
    let(:building) { build(:building) }

    context 'when no image is attached' do
      before do
        allow(building).to receive(:building_image).and_return(double(attached?: false))
      end

      it 'does not add errors' do
        building.send(:acceptable_image)
        expect(building.errors).to be_empty
      end
    end

    context 'when valid image is attached' do
      before do
        valid_image = double('image', 
          attached?: true,
          blob: double('blob', byte_size: 5.megabytes),
          content_type: 'image/png',
          name: 'building_image'
        )
        allow(building).to receive(:building_image).and_return(valid_image)
      end

      it 'does not add errors' do
        building.send(:acceptable_image)
        expect(building.errors).to be_empty
      end
    end
  end

  describe 'primary key' do
    it 'uses bldrecnbr as primary key' do
      expect(Building.primary_key).to eq('bldrecnbr')
    end
  end

  describe 'factory' do
    it 'creates valid building' do
      building = build(:building)
      expect(building).to be_valid
    end

    it 'creates building with unique bldrecnbr' do
      building1 = create(:building)
      building2 = create(:building)
      expect(building1.bldrecnbr).not_to eq(building2.bldrecnbr)
    end

    context 'with traits' do
      it 'creates inactive building' do
        building = create(:building, :inactive)
        expect(building.visible).to be false
      end
    end
  end
end