require "rails_helper"

RSpec.describe "Users::TestSessions", type: :request do
  def stub_test_login_env(overrides = {})
    values = {
      "ENABLE_TEST_LOGIN" => "true",
      "TEST_LOGIN_TOKEN" => "secret-token",
      "TEST_LOGIN_EMAIL" => "test.login@umich.edu",
      "TEST_LOGIN_GROUPS" => nil
    }.merge(overrides)

    allow(ENV).to receive(:[]).and_call_original
    values.each do |key, value|
      allow(ENV).to receive(:[]).with(key).and_return(value)
    end
  end

  let!(:building) do
    create(
      :building,
      bldrecnbr: 4_000_101,
      name: "Chemistry Building",
      visible: true
    )
  end
  let!(:room) do
    create(
      :room,
      building_bldrecnbr: building.bldrecnbr,
      rmrecnbr: 1_200_101,
      rmtyp_description: "Classroom",
      facility_code_heprod: "CHEM1800",
      instructional_seating_count: 90,
      visible: true
    )
  end

  describe "GET /test_login" do
    it "creates a signed-in admin session when using the default memberships" do
      stub_test_login_env

      get test_login_path(token: "secret-token")

      expect(response).to redirect_to(root_path)
      expect(User.find_by(email: "test.login@umich.edu")).to be_present

      get buildings_path(format: :json)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first["bldrecnbr"]).to eq(building.bldrecnbr)
    end

    it "creates a signed-in non-admin session when using non-admin groups" do
      stub_test_login_env("TEST_LOGIN_GROUPS" => "mi-classrooms-non-admin-staging")

      get test_login_path(token: "secret-token")

      expect(response).to redirect_to(root_path)

      get buildings_path(format: :json)

      expect(response).to redirect_to(about_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "returns not found for an invalid token" do
      stub_test_login_env

      get test_login_path(token: "wrong-token")

      expect(response).to have_http_status(:not_found)
    end
  end
end
