require 'rails_helper'

RSpec.describe TaskResultLog do
  describe '#update_log' do
    let(:log) { described_class.new }
    let(:message) { "Test message" }
    let(:debug) { false }

    context 'when ApiUpdateLog record fails to save' do
      before do
        allow(ApiUpdateLog).to receive(:create).and_return(false)
      end

      it 'logs an error message to the file' do
        expect(ApiLog.instance.logger).to receive(:debug).with(/API Update Log Error:/)
        log.update_log(message, debug)
      end
    end
  end
end