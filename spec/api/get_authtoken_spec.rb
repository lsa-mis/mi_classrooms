require 'rails_helper'

RSpec.describe AuthTokenApi do
  describe '#get_auth_token' do
    let(:scope) { 'test_scope' }
    subject(:auth_token_api) { described_class.new(scope) }

    context 'when the access token is successfully retrieved' do
      before do
        allow(auth_token_api).to receive(:request_auth_token).and_return({'access_token' => 'test_token'})
      end

      it 'returns a hash with success: true and the access token' do
        expected_response = {
          'success' => true,
          'error' => '',
          'access_token' => 'test_token'
        }

        expect(auth_token_api.get_auth_token).to eq(expected_response)
      end
    end

    context 'when there is an error retrieving the access token' do
      before do
        allow(auth_token_api).to receive(:request_auth_token).and_return({'fault' => {'faultstring' => 'Error message'}})
      end

      it 'returns a hash with success: false and the error message' do
        expected_response = {
          'success' => false,
          'error' => 'Error message',
          'access_token' => nil
        }

        expect(auth_token_api.get_auth_token).to eq(expected_response)
      end
    end
  end
end