require 'rails_helper'

RSpec.describe ApiUpdateLog, type: :model do
  describe 'factory' do
    it 'creates valid api update log' do
      log = build(:api_update_log)
      expect(log).to be_valid
    end

    it 'creates log with required attributes' do
      log = create(:api_update_log)
      expect(log.result).to be_present
      expect(log.status).to be_present
    end
  end

  describe 'attributes' do
    let(:log) { create(:api_update_log) }

    it 'has result' do
      expect(log.result).to be_present
    end

    it 'has status' do
      expect(['success', 'failed', 'in_progress']).to include(log.status)
    end

    it 'has created_at timestamp' do
      expect(log.created_at).to be_a(Time)
    end
  end
end
