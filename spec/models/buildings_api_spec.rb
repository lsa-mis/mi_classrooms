require 'rails_helper'

RSpec.describe BuildingsApi, type: :model do

  it "get_campuses works" do
    auth_token_api = AuthTokenApi.new("buildings")
    access_token = auth_token_api.get_auth_token
    api = BuildingsApi.new(access_token)
    result = api.get_campuses
    expect(result['success']).to be true
    expect(result['errorcode']).to eq('')
    expect(result['error']).to eq('')
    expect(result['data']).not_to be(nil)
    expect(result['data']).to be_a(Hash)
  end

end