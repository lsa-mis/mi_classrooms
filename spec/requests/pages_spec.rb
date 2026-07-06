require "rails_helper"

RSpec.describe "Pages", type: :request do
  include Devise::Test::IntegrationHelpers

  def force_membership(admin:)
    allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
      next unless controller.current_user

      controller.current_user.membership = [admin ? "mi-classrooms-admin-staging" : "mi-classrooms-non-admin-staging"]
      controller.current_user.admin = admin
    end
  end

  let(:user) { create(:user) }

  before do
    stub_request_layout_partials
  end

  describe "GET /" do
    it "loads home for guests" do
      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "redirects signed-in viewers to rooms" do
      sign_in user, scope: :user
      force_membership(admin: false)

      get root_path

      expect(response).to redirect_to(rooms_path)
    end
  end

  describe "GET /about" do
    it "loads the about page" do
      get about_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /room_filters_glossary" do
    before do
      building = create(:building)
      room = create(:room, building_bldrecnbr: building.bldrecnbr)
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc_descrshort: "Projector", chrstc_desc254: "Projection display")
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc_descrshort: "Whiteboard", chrstc_desc254: "Wall whiteboard")
    end

    it "requires authentication" do
      get room_filters_glossary_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "allows authenticated users" do
      sign_in user, scope: :user
      force_membership(admin: false)

      get room_filters_glossary_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Room Filters Glossary")
      expect(response.body).to include("Projection display")
    end
  end
end
