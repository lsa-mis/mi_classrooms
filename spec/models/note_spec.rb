require 'rails_helper'

RSpec.describe Note, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:noteable) }
    it { should belong_to(:parent).optional.class_name('Note') }
    it { should have_many(:notes).with_foreign_key('parent_id').dependent(:destroy) }
    it { should have_rich_text(:body) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'scopes' do
    let!(:alert_note) { create(:note, alert: true) }
    let!(:regular_note) { create(:note, alert: false) }

    describe '.alert' do
      it 'returns only alert notes' do
        expect(Note.alert).to include(alert_note)
        expect(Note.alert).not_to include(regular_note)
      end

      it 'orders by updated_at desc' do
        # Clear existing notes to avoid interference
        Note.destroy_all
        
        # Create notes with explicit time differences
        older_alert = create(:note, alert: true)
        sleep(0.01)  # Ensure time difference
        newer_alert = create(:note, alert: true)
        
        # Update timestamps to ensure proper ordering
        older_alert.update_column(:updated_at, 2.hours.ago)
        newer_alert.update_column(:updated_at, 1.hour.ago)
        
        alerts = Note.alert.to_a
        expect(alerts.first).to eq(newer_alert)
        expect(alerts.last).to eq(older_alert)
      end
    end

    describe '.notice' do
      it 'returns only non-alert notes' do
        expect(Note.notice).to include(regular_note)
        expect(Note.notice).not_to include(alert_note)
      end

      it 'orders by updated_at desc' do
        # Clear existing notes to avoid interference  
        Note.destroy_all
        
        # Create notes with explicit time differences
        older_notice = create(:note, alert: false)
        sleep(0.01)  # Ensure time difference
        newer_notice = create(:note, alert: false)
        
        # Update timestamps to ensure proper ordering
        older_notice.update_column(:updated_at, 2.hours.ago)
        newer_notice.update_column(:updated_at, 1.hour.ago)
        
        notices = Note.notice.to_a
        expect(notices.first).to eq(newer_notice)
        expect(notices.last).to eq(older_notice)
      end
    end
  end

  # Broadcast tests commented out - require Turbo Stream testing setup
  # describe 'callbacks' do
  #   let(:user) { create(:user) }
  #   let(:room) { create(:room) }

  #   describe 'after_create_commit' do
  #     it 'executes callback without errors' do
  #       expect {
  #         create(:note, user: user, noteable: room, alert: true)
  #       }.not_to raise_error
  #     end
  #   end
  # end

  describe 'parent-child relationships' do
    let(:parent_note) { create(:note) }
    let(:child_note) { create(:note, parent: parent_note) }

    it 'allows notes to have child notes' do
      expect(parent_note.notes).to include(child_note)
    end

    it 'allows notes to have parent notes' do
      expect(child_note.parent).to eq(parent_note)
    end

    it 'destroys child notes when parent is destroyed' do
      child_note # create the child note
      expect {
        parent_note.destroy!
      }.to change(Note, :count).by(-2) # parent and child
    end
  end

  describe 'polymorphic associations' do
    let(:room) { create(:room) }
    let(:building) { create(:building) }
    let(:user) { create(:user) }

    it 'can be associated with a room' do
      note = create(:note, user: user, noteable: room)
      expect(note.noteable).to eq(room)
      expect(note.noteable_type).to eq('Room')
    end

    it 'can be associated with a building' do
      note = create(:note, user: user, noteable: building)
      expect(note.noteable).to eq(building)
      expect(note.noteable_type).to eq('Building')
    end
  end

  describe 'factory' do
    it 'creates valid note' do
      note = build(:note)
      expect(note).to be_valid
    end

    it 'creates note with required associations' do
      note = create(:note)
      expect(note.user).to be_present
      expect(note.noteable).to be_present
    end

    it 'creates non-alert note by default' do
      note = create(:note)
      expect(note.alert).to be false
    end
  end
end