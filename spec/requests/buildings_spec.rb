require "rails_helper"

RSpec.describe "Buildings", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user) }
  let!(:matching_building) do
    create(
      :building,
      bldrecnbr: 3_000_101,
      name: "Mason Hall",
      nick_name: "Mason",
      abbreviation: "MH",
      address: "419 State Street",
      city: "Ann Arbor",
      state: "MI",
      zip: "48109",
      country: "United States",
      visible: true
    )
  end
  let!(:classroom) do
    create(
      :room,
      building_bldrecnbr: matching_building.bldrecnbr,
      rmrecnbr: 1_100_101,
      rmtyp_description: "Classroom",
      facility_code_heprod: "MH1400",
      instructional_seating_count: 120,
      visible: true
    )
  end
  let!(:building_without_classroom) do
    create(
      :building,
      bldrecnbr: 3_000_102,
      name: "Admin Annex",
      visible: true
    )
  end

  before do
    sign_in admin, scope: :user

    allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
      next unless controller.current_user

      controller.current_user.membership = ["mi-classrooms-admin-staging"]
      controller.current_user.admin = true
    end
  end

  describe "GET /buildings.json" do
    it "returns the buildings json payload for admin users" do
      get buildings_path(format: :json)

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json.size).to eq(1)
      expect(json.first["bldrecnbr"]).to eq(matching_building.bldrecnbr)
      expect(json.first["name"]).to eq("Mason Hall")
      expect(json.first["url"]).to eq(building_url(matching_building, format: :json))
    end
  end

  describe "GET /buildings/:id.json" do
    it "returns the building json payload for admin users" do
      get building_path(matching_building, format: :json)

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["bldrecnbr"]).to eq(matching_building.bldrecnbr)
      expect(json["name"]).to eq("Mason Hall")
      expect(json["abbreviation"]).to eq("MH")
      expect(json["url"]).to eq(building_url(matching_building, format: :json))
    end
  end
end
