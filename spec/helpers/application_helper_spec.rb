# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#api_status' do
    it 'returns failed when no ApiUpdateLog exists in the last 24 hours' do
      ApiUpdateLog.create!(
        result: 'stale success',
        status: 'success',
        created_at: 25.hours.ago
      )

      expect(helper.api_status).to eq('failed')
    end

    it 'returns error when the newest log from the last 24 hours has error status' do
      ApiUpdateLog.create!(
        result: 'earlier success',
        status: 'success',
        created_at: 2.hours.ago
      )
      ApiUpdateLog.create!(
        result: 'department sync failed',
        status: 'error',
        created_at: 1.hour.ago
      )

      expect(helper.api_status).to eq('error')
    end

    it 'returns nil when the newest log from the last 24 hours succeeded' do
      ApiUpdateLog.create!(
        result: 'earlier error',
        status: 'error',
        created_at: 2.hours.ago
      )
      ApiUpdateLog.create!(
        result: 'nightly update finished',
        status: 'success',
        created_at: 30.minutes.ago
      )

      expect(helper.api_status).to be_nil
    end
  end

  describe '#api_log_text' do
    it 'returns the newest recent log result when present' do
      ApiUpdateLog.create!(
        result: 'Counts: updated=3',
        status: 'error',
        created_at: 1.hour.ago
      )

      expect(helper.api_log_text).to eq('Counts: updated=3')
    end

    it 'returns a fallback message when the newest recent log result is blank' do
      ApiUpdateLog.create!(
        result: '',
        status: 'error',
        created_at: 1.hour.ago
      )

      expect(helper.api_log_text).to eq('The log message is empty')
    end
  end
end
