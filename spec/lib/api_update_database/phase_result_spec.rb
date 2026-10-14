# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiUpdateDatabase::PhaseResult do
  describe '#increment' do
    it 'adds to known counters and tracks unknown counters separately' do
      result = described_class.new('Update Rooms')

      result.increment(:updated, 2)
      result.increment(:updated)
      result.increment(:custom_metric, 3)

      expect(result.counters[:updated]).to eq(3)
      expect(result.counters[:custom_metric]).to eq(3)
      expect(result.counters[:created]).to eq(0)
    end
  end

  describe '#finish' do
    it 'is idempotent and enables duration calculation' do
      result = described_class.new('Update buildings')
      first_finish = result.finish
      finished_at = result.finished_at

      expect(first_finish).to equal(result)
      expect(result.finish.finished_at).to eq(finished_at)
      expect(result.duration_seconds).to be >= 0
    end

    it 'returns nil duration before finish' do
      result = described_class.new('Update campus list')

      expect(result.duration_seconds).to be_nil
    end
  end

  describe '#success?' do
    it 'is true until an error is recorded' do
      result = described_class.new('Update Rooms')
      result.add_warning('slow response')

      expect(result).to be_success

      result.add_error('Rooms updates failed.')

      expect(result).not_to be_success
    end
  end

  describe '#to_h' do
    it 'serializes counters, warnings, errors, and metadata for structured logs' do
      result = described_class.new('Update classroom contacts')
      result.increment(:api_calls, 4)
      result.increment(:deactivated, 1)
      result.add_warning('rate limited once')
      result.add_metadata(:campus, 'AA')
      result.add_error('token expired')
      result.finish

      payload = result.to_h

      expect(payload).to include(
        phase: 'Update classroom contacts',
        status: 'error',
        warnings: ['rate limited once'],
        errors: ['token expired'],
        metadata: { campus: 'AA' }
      )
      expect(payload[:started_at]).to eq(result.started_at.iso8601)
      expect(payload[:finished_at]).to eq(result.finished_at.iso8601)
      expect(payload[:duration_seconds]).to eq(result.duration_seconds.round(2))
      expect(payload[:counters]).to include(api_calls: 4, deactivated: 1, created: 0)
    end
  end
end
