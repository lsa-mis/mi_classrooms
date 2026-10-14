# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiUpdateDatabase::RunResult do
  def build_phase(name, error: nil)
    phase = ApiUpdateDatabase::PhaseResult.new(name)
    phase.add_error(error) if error
    phase.finish
  end

  describe '#success?' do
    it 'is true only when every phase succeeded' do
      success = described_class.new(
        started_at: Time.current,
        finished_at: Time.current,
        phases: [build_phase('Update campus list'), build_phase('Update buildings')]
      )
      failure = described_class.new(
        started_at: Time.current,
        finished_at: Time.current,
        phases: [build_phase('Update campus list'), build_phase('Update buildings', error: 'boom')]
      )

      expect(success).to be_success
      expect(failure).not_to be_success
    end
  end

  describe '#to_h' do
    it 'rolls phase payloads into a top-level structured report' do
      started_at = Time.utc(2026, 9, 30, 10, 0, 0)
      finished_at = started_at + 2
      phase = build_phase('Update Rooms', error: 'Rooms updates failed.')
      phase.increment(:updated, 5)

      result = described_class.new(
        started_at: started_at,
        finished_at: finished_at,
        phases: [phase]
      )
      payload = result.to_h

      expect(payload).to include(
        status: 'error',
        started_at: started_at.iso8601,
        finished_at: finished_at.iso8601,
        duration_seconds: 2.0
      )
      expect(payload[:phases].size).to eq(1)
      expect(payload[:phases].first).to include(
        phase: 'Update Rooms',
        status: 'error',
        errors: ['Rooms updates failed.']
      )
      expect(payload[:phases].first[:counters][:updated]).to eq(5)
    end
  end
end
