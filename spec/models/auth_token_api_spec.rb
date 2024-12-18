require 'rails_helper'

RSpec.describe AuthTokenApi, type: :model do

  context "the scope is not correct (hotdogs)" do
    let!(:auth_token_api) { AuthTokenApi.new("hotdogs") }

    before do
      response = double()
      allow(response).to receive(:code).and_return("401")
      allow(response).to receive(:read_body).and_return('{"fault": {"faultstring": "Invalid Scope", "detail": {"errorcode": "oauth.v2.InvalidScope"}}}')
      allow(auth_token_api).to receive(:http_call).and_return(response)
    end

    it "returns Invalid Scope error" do
      auth_token = auth_token_api.get_auth_token
      expect(auth_token).to be false
      expect(ApiUpdateLog.last.status).to eq("error")
      expect(ApiUpdateLog.last.result).to include("Invalid Scope")
    end
  end

  context "the scope is correct (buildings)" do
    let!(:auth_token_api) { AuthTokenApi.new("buildings") }

    before do
      response = double()
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:read_body).and_return('{"token_type": "Bearer", "access_token": "2wq00IPhXzA7g6dSlh7qHzf2CgZD", "issued_at": 1734533939, "expires_in": 3599, "scope": "buildings", "client_id": "89z6gUkueEDqBQOAzemfpqSByTGJCBnlOGXtNpsG2bnQ1zFs"}')
      allow(auth_token_api).to receive(:http_call).and_return(response)
    end

    it "returns valid token for 'buildings' scope" do
      auth_token = auth_token_api.get_auth_token
      expect(auth_token).to eq("2wq00IPhXzA7g6dSlh7qHzf2CgZD")
    end
  end

  context "rescue error if http_call failed" do
    let!(:auth_token_api) { AuthTokenApi.new("buildings") }

    before do
      allow(auth_token_api).to receive(:http_call).and_return("abc")
    end
    
    it "logs the error" do
      auth_token = auth_token_api.get_auth_token
      expect(ApiUpdateLog.last.status).to eq("error")
      expect(ApiUpdateLog.last.result).to include("undefined method `read_body' for an instance of String")
    end
  end

end
