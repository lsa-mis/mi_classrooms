require "rails_helper"

RSpec.describe UmApi::TokenStore do
  describe "#fetch" do
    it "caches tokens by scope until they expire" do
      token_store = described_class.new
      connection = instance_double(UmApi::Connection)

      allow(UmApi::Connection).to receive(:new).and_return(connection)
      allow(connection).to receive(:post_form).and_return(
        {
          "success" => true,
          "error" => "",
          "data" => {
            "access_token" => "buildings-token",
            "expires_in" => "3600"
          }
        }
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
