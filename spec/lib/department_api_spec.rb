require "rails_helper"

RSpec.describe DepartmentApi do
  let(:client) { instance_double(UmApi::Connection) }
  let(:api) { described_class.new("dept-token") }

  before do
    allow(UmApi::Connection).to receive(:new)
      .with(access_token: "dept-token", scope: "department")
      .and_return(client)
  end

  describe "#get_departments_info" do
    it "returns the normalized success payload with DepartmentList as data" do
      allow(client).to receive(:get_json).and_return(
        "success" => true,
        "data" => {
          "DepartmentList" => {
            "DeptData" => [{"DeptDescription" => "Mathematics", "DeptId" => "123"}]
          }
        }
      )

      result = api.get_departments_info("Mathematics")

      expect(result).to eq(
        "success" => true,
        "errorcode" => "",
        "error" => "",
        "data" => {
          "DeptData" => [{"DeptDescription" => "Mathematics", "DeptId" => "123"}]
        }
      )
      expect(client).to have_received(:get_json).with(
        "#{DepartmentApi::BASE_URL}/DeptData",
        query: {DeptDescription: "Mathematics"}
      )
    end

    it "passes through unsuccessful API responses without rewriting them" do
      failure = {
        "success" => false,
        "errorcode" => "HTTP 404",
        "error" => "Department not found",
        "data" => {}
      }
      allow(client).to receive(:get_json).and_return(failure)

      expect(api.get_departments_info("Missing Dept")).to eq(failure)
    end
  end

  describe "#get_all_departments_info" do
    it "delegates to paginated_get with the DepartmentList/DeptData collection path" do
      pages = {
        "success" => true,
        "data" => [{"DeptDescription" => "History", "DeptId" => "9"}]
      }
      allow(client).to receive(:paginated_get).and_return(pages)

      expect(api.get_all_departments_info).to eq(pages)
      expect(client).to have_received(:paginated_get).with(
        "#{DepartmentApi::BASE_URL}/DeptData",
        collection_path: %w[DepartmentList DeptData]
      )
    end
  end
end
