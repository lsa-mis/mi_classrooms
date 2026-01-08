require 'rails_helper'

RSpec.describe Note, type: :model do
  let!(:user) { create(:user) }
  let!(:building) { create(:building, bldrecnbr: 1234567) }
  let!(:room) { create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 9999999) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:noteable) }
    it { should belong_to(:parent).class_name('Note').optional }
    it { should have_many(:notes).with_foreign_key(:parent_id).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }

    it 'is valid with required attributes' do
      note = Note.new(user: user, noteable: room, body: 'Test note content')
      expect(note).to be_valid
    end

    it 'is not valid without body' do
      note = Note.new(user: user, noteable: room, body: nil)
      expect(note).not_to be_valid
    end

    it 'is not valid with blank body' do
      note = Note.new(user: user, noteable: room, body: '')
      expect(note).not_to be_valid
    end
  end

  describe 'polymorphic associations' do
    it 'can belong to a room' do
      note = Note.create!(user: user, noteable: room, body: 'Room note')
      expect(note.noteable).to eq(room)
      expect(note.noteable_type).to eq('Room')
    end

    it 'can belong to a building' do
      note = Note.create!(user: user, noteable: building, body: 'Building note')
      expect(note.noteable).to eq(building)
      expect(note.noteable_type).to eq('Building')
    end
  end

  describe 'scopes' do
    let!(:alert_note1) { Note.create!(user: user, noteable: room, body: 'Alert 1', alert: true, updated_at: 2.days.ago) }
    let!(:alert_note2) { Note.create!(user: user, noteable: room, body: 'Alert 2', alert: true, updated_at: 1.day.ago) }
    let!(:notice_note1) { Note.create!(user: user, noteable: room, body: 'Notice 1', alert: false, updated_at: 2.days.ago) }
    let!(:notice_note2) { Note.create!(user: user, noteable: room, body: 'Notice 2', alert: false, updated_at: 1.day.ago) }

    describe '.alert' do
      it 'returns only alert notes' do
        results = Note.alert
        expect(results).to include(alert_note1, alert_note2)
        expect(results).not_to include(notice_note1, notice_note2)
      end

      it 'orders by updated_at descending' do
        results = Note.alert
        expect(results.first).to eq(alert_note2)
        expect(results.last).to eq(alert_note1)
      end
    end

    describe '.notice' do
      it 'returns only non-alert notes' do
        results = Note.notice
        expect(results).to include(notice_note1, notice_note2)
        expect(results).not_to include(alert_note1, alert_note2)
      end

      it 'orders by updated_at descending' do
        results = Note.notice
        expect(results.first).to eq(notice_note2)
        expect(results.last).to eq(notice_note1)
      end
    end
  end

  describe 'threading (parent/child notes)' do
    let!(:parent_note) { Note.create!(user: user, noteable: room, body: 'Parent note') }

    it 'can have child notes' do
      child_note = Note.create!(user: user, noteable: room, body: 'Child note', parent: parent_note)
      expect(parent_note.notes).to include(child_note)
      expect(child_note.parent).to eq(parent_note)
    end

    it 'destroys child notes when parent is destroyed' do
      child_note = Note.create!(user: user, noteable: room, body: 'Child note', parent: parent_note)
      expect { parent_note.destroy }.to change(Note, :count).by(-2)
    end
  end

  describe 'rich text body' do
    it 'supports ActionText rich text' do
      note = Note.create!(user: user, noteable: room, body: '<strong>Bold text</strong>')
      expect(note.body.to_s).to include('Bold text')
    end
  end
end
