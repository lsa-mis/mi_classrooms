require "rails_helper"

RSpec.describe UmApi::TokenStore do
  def stub_token_store(token_store, connection:)
    allow(UmApi::Connection).to receive(:new).and_return(connection)
    allow(token_store).to receive(:credentials).and_return(
      buildings_client_id: "client-id",
      buildings_client_secret: "client-secret"
    )
  end

  def successful_token_response(access_token:, expires_in: "3600")
    {
      "success" => true,
      "error" => "",
      "data" => {
        "access_token" => access_token,
        "expires_in" => expires_in
      }
    }
  end

  describe "#fetch" do
    it "caches tokens by scope until they expire" do
      token_store = described_class.new
      connection = instance_double(UmApi::Connection)
      stub_token_store(token_store, connection: connection)
      allow(connection).to receive(:post_form).and_return(
        successful_token_response(access_token: "buildings-token")
      )

      first_result = token_store.fetch("buildings")
      second_result = token_store.fetch("buildings")

      expect(first_result).to eq(
        "success" => true,
        "error" => "",
        "access_token" => "buildings-token"
      )
      expect(second_result).to eq(first_result)
      expect(connection).to have_received(:post_form).once
    end

    it "refreshes a cached token once it has expired" do
      token_store = described_class.new
      connection = instance_double(UmApi::Connection)
      stub_token_store(token_store, connection: connection)
      allow(connection).to receive(:post_form).and_return(
        successful_token_response(access_token: "first-token", expires_in: "60"),
        successful_token_response(access_token: "second-token")
      )

      first_result = token_store.fetch("buildings")
      # expires_in of 60 becomes expires_at = now after the 60s buffer subtraction
      expect(first_result["access_token"]).to eq("first-token")

      second_result = token_store.fetch("buildings")

      expect(second_result["access_token"]).to eq("second-token")
      expect(connection).to have_received(:post_form).twice
    end

    it "returns a failure result when the token endpoint succeeds without an access_token" do
      token_store = described_class.new
      connection = instance_double(UmApi::Connection)
      stub_token_store(token_store, connection: connection)
      allow(connection).to receive(:post_form).and_return(
        {
          "success" => true,
          "error" => "missing token",
          "data" => {}
        }
      )

      result = token_store.fetch("buildings")

      expect(result).to eq(
        "success" => false,
        "error" => "missing token",
        "access_token" => nil
      )
    end

    it "returns a failure result when the token endpoint reports failure" do
      token_store = described_class.new
      connection = instance_double(UmApi::Connection)
      stub_token_store(token_store, connection: connection)
      allow(connection).to receive(:post_form).and_return(
        {
          "success" => false,
          "error" => "invalid_client",
          "data" => {}
        }
      )

      result = token_store.fetch("buildings")

      expect(result).to eq(
        "success" => false,
        "error" => "invalid_client",
        "access_token" => nil
      )
    end

    it "wraps unexpected exceptions as a failure result" do
      token_store = described_class.new
      connection = instance_double(UmApi::Connection)
      stub_token_store(token_store, connection: connection)
      allow(connection).to receive(:post_form).and_raise(SocketError.new("dns failed"))

      result = token_store.fetch("buildings")

      expect(result["success"]).to be(false)
      expect(result["access_token"]).to be_nil
      expect(result["error"]).to include("SocketError")
      expect(result["error"]).to include("dns failed")
    end
  end
end


RSpec.describe UmApi::Connection do
  describe "#paginated_get" do
    it "aggregates paginated responses until there is no next link" do
      connection = described_class.new(access_token: "token")
      first_page = {
        "success" => true,
        "errorcode" => "",
        "error" => "",
        "data" => {
          "ListOfBldgs" => {
            "Buildings" => [{"BuildingRecordNumber" => "1001"}]
          }
        },
        "headers" => {"link" => ["<https://example.test>; rel=next"]}
      }
      second_page = {
        "success" => true,
        "errorcode" => "",
        "error" => "",
        "data" => {
          "ListOfBldgs" => {
            "Buildings" => [{"BuildingRecordNumber" => "1002"}]
          }
        },
        "headers" => {}
      }

      allow(connection).to receive(:get_json).and_return(first_page, second_page)

      result = connection.paginated_get(
        "https://example.test/buildings",
        collection_path: %w[ListOfBldgs Buildings]
      )

      expect(result["success"]).to be(true)
      expect(result["data"]).to eq(
        [
          {"BuildingRecordNumber" => "1001"},
          {"BuildingRecordNumber" => "1002"}
        ]
      )
      expect(connection).to have_received(:get_json)
        .with("https://example.test/buildings", query: {"$start_index" => 0, "$count" => 1000})
        .ordered
      expect(connection).to have_received(:get_json)
        .with("https://example.test/buildings", query: {"$start_index" => 1000, "$count" => 1000})
        .ordered
    end
  end

  describe "#extract_error_code" do
    let(:connection) { described_class.new(access_token: "token") }

    it "prefers the API errorCode when present" do
      expect(connection.send(:extract_error_code, {"errorCode" => "BF-123"}, "500")).to eq("BF-123")
    end

    it "returns Fault when the body carries a fault object" do
      expect(connection.send(:extract_error_code, {"fault" => {"faultstring" => "boom"}}, "500")).to eq("Fault")
    end

    it "falls back to the HTTP status code when no known error key is present" do
      expect(connection.send(:extract_error_code, {}, "429")).to eq("HTTP 429")
    end

    it "returns Unknown error when there is neither a known key nor a status code" do
      expect(connection.send(:extract_error_code, {}, nil)).to eq("Unknown error")
    end
  end

  describe "#extract_error_message" do
    let(:connection) { described_class.new(access_token: "token") }

    it "prefers the API errorMessage when present" do
      expect(connection.send(:extract_error_message, {"errorMessage" => "Not found"})).to eq("Not found")
    end

    it "uses the fault faultstring when present" do
      expect(connection.send(:extract_error_message, {"fault" => {"faultstring" => "Rate limit exceeded"}}))
        .to eq("Rate limit exceeded")
    end

    it "uses a generic error key when present" do
      expect(connection.send(:extract_error_message, {"error" => "bad request"})).to eq("bad request")
    end

    it "falls back to a raw body snippet when no known message key is present" do
      expect(connection.send(:extract_error_message, {"unexpected" => "shape"}))
        .to eq("{\"unexpected\":\"shape\"}")
    end
  end

  describe "#raw_body_snippet" do
    let(:connection) { described_class.new(access_token: "token") }

    it "reports when there is no usable response body" do
      expect(connection.send(:raw_body_snippet, {})).to eq("no response body returned")
      expect(connection.send(:raw_body_snippet, "")).to eq("no response body returned")
    end

    it "serializes a hash body to JSON" do
      expect(connection.send(:raw_body_snippet, {"a" => 1})).to eq("{\"a\":1}")
    end

    it "returns a string body as-is" do
      expect(connection.send(:raw_body_snippet, "upstream timeout")).to eq("upstream timeout")
    end

    it "truncates very long bodies to 200 characters" do
      snippet = connection.send(:raw_body_snippet, "x" * 500)
      expect(snippet.length).to eq(200)
      expect(snippet).to end_with("...")
    end
  end

  describe "#get_json (request_json behavior)" do
    let(:connection) { described_class.new(access_token: "token") }

    def fake_response(code:, body:, headers: {})
      instance_double(Net::HTTPResponse, code: code, body: body, to_hash: headers)
    end

    def stub_http_response(response)
      http = instance_double(Net::HTTP)
      allow(connection).to receive(:http_for).and_return(http)
      allow(http).to receive(:request).and_return(response)
      http
    end

    before do
      allow(connection).to receive(:credentials).and_return(buildings_client_id: "client-id")
    end

    it "returns a success result with parsed data and headers on a 200 response" do
      stub_http_response(
        fake_response(
          code: "200",
          body: {"DepartmentList" => {"DeptData" => []}}.to_json,
          headers: {"content-type" => ["application/json"]}
        )
      )

      result = connection.get_json("https://example.test/data")

      expect(result["success"]).to be(true)
      expect(result["data"]).to eq("DepartmentList" => {"DeptData" => []})
      expect(result["headers"]).to eq("content-type" => ["application/json"])
    end

    it "returns a failure result carrying the HTTP status code when the body has no known error keys" do
      stub_http_response(fake_response(code: "429", body: ""))

      result = connection.get_json("https://example.test/data")

      expect(result["success"]).to be(false)
      expect(result["errorcode"]).to eq("HTTP 429")
      expect(result["error"]).to eq("no response body returned")
    end

    it "surfaces the API errorCode and errorMessage on a structured error body" do
      stub_http_response(
        fake_response(
          code: "404",
          body: {"errorCode" => "BF-404", "errorMessage" => "Department not found"}.to_json
        )
      )

      result = connection.get_json("https://example.test/data")

      expect(result["success"]).to be(false)
      expect(result["errorcode"]).to eq("BF-404")
      expect(result["error"]).to eq("Department not found")
    end

    it "wraps unexpected exceptions as an Exception failure result" do
      http = instance_double(Net::HTTP)
      allow(connection).to receive(:http_for).and_return(http)
      allow(http).to receive(:request).and_raise(SocketError.new("getaddrinfo failed"))

      result = connection.get_json("https://example.test/data")

      expect(result["success"]).to be(false)
      expect(result["errorcode"]).to eq("Exception")
      expect(result["error"]).to eq("getaddrinfo failed")
    end
  end
end

RSpec.describe AuthTokenApi do
  describe "#get_auth_token" do
    it "delegates token lookup to the shared token store" do
      token_store = instance_double(UmApi::TokenStore)
      result = {"success" => true, "error" => "", "access_token" => "cached-token"}

      allow(UmApi).to receive(:token_store).and_return(token_store)
      allow(token_store).to receive(:fetch).with("buildings").and_return(result)

      expect(described_class.new("buildings").get_auth_token).to eq(result)
    end
  end
end
