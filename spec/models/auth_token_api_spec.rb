require 'rails_helper'

RSpec.describe AuthTokenApi, type: :model do

  it "returns Invalid Scope error" do
    auth_token_api = AuthTokenApi.new("buildings1")
    auth_token = auth_token_api.get_auth_token
    expect(auth_token).to be false
    expect(ApiUpdateLog.last.status).to eq("error")
    expect(ApiUpdateLog.last.result).to include("Invalid Scope")
  end

  it "returns valid token for 'buildings' scope" do
    auth_token_api = AuthTokenApi.new("buildings")
    auth_token = auth_token_api.get_auth_token
    expect(auth_token).to be_a(String)
  end

end