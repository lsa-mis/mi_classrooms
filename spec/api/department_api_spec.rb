require 'rails_helper'
require 'webmock/rspec'

RSpec.describe DepartmentApi do
  describe '#get_departments_info' do
    let(:access_token) { 'test_access_token' }
    let(:department_name) { 'Test Department' }
    let(:api_instance) { DepartmentApi.new(access_token) }
    let(:base_url) { "https://gw.api.it.umich.edu/um/bf/Department/v2/DeptData?DeptDescription=#{URI.encode_www_form_component(department_name)}" }
    let(:headers) {
      {
        'Accept' => 'application/json',
        'Authorization' => "Bearer #{access_token}",
        'X-Ibm-Client-Id' => Rails.application.credentials.um_api[:buildings_client_id].to_s
      }
    }    

    context 'when the API call is successful' do
      before do
        stub_request(:get, base_url)
          .with(headers: headers)
          .to_return(status: 200, body: { 'DepartmentList' => [{ 'DeptName' => 'Test Department' }] }.to_json)
      end

      it 'returns a hash with success: true and the correct data' do
        expected_response = {
          'success' => true,
          'data' => [{ 'DeptName' => 'Test Department' }]
        }
        expect(api_instance.get_departments_info(department_name)).to eq(expected_response)
      end
    end

    context 'when the API returns an error' do
      before do
        stub_request(:get, base_url)
          .with(headers: headers)
          .to_return(status: 400, body: { 'errorCode' => '400', 'errorMessage' => 'Bad Request' }.to_json)
      end

      it 'returns a hash with success: false and the error message' do
        expected_response = {
          'success' => false,
          'errorcode' => '400',
          'error' => 'Bad Request'
        }
        expect(api_instance.get_departments_info(department_name)).to eq(expected_response)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        # Simulate a network-related exception, e.g., timeout
        stub_request(:get, base_url)
          .with(headers: headers)
          .to_raise(StandardError.new('Unexpected error'))
      end
    
      it 'captures the exception and returns a descriptive error message' do
        expected_response = {
          'success' => false,
          'errorcode' => 'Exception',
          'error' => 'Unexpected error'
        }
        expect(api_instance.get_departments_info(department_name)).to eq(expected_response)
      end
    end
  end
end