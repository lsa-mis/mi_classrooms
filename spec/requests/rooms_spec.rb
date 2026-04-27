require "rails_helper"

RSpec.describe "Rooms", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:viewer) { create(:user) }
  let!(:building) do
    create(
      :building,
      bldrecnbr: 2_000_101,
      name: "Undergraduate Science Building",
      address: "123 State Street",
      city: "Ann Arbor",
      zip: "48109",
      visible: true
    )
  end
  let!(:matching_room) do
    create(
      :room,
      building_bldrecnbr: building.bldrecnbr,
      rmrecnbr: 1_000_101,
      room_number: "101",
      facility_code_heprod: "USB101",
      rmtyp_description: "Classroom",
      instructional_seating_count: 40,
      visible: true
    )
  end
  let!(:other_room) do
    create(
      :room,
      building_bldrecnbr: building.bldrecnbr,
      rmrecnbr: 1_000_102,
      room_number: "202",
      facility_code_heprod: "USB202",
      rmtyp_description: "Classroom",
      instructional_seating_count: 80,
      visible: true
    )
  end

  before do
    sign_in viewer, scope: :user

    allow_any_instance_of(ActionView::Base).to receive(:stylesheet_link_tag).and_return("")
    allow_any_instance_of(Importmap::ImportmapTagsHelper).to receive(:javascript_importmap_tags).and_return("")
    allow_any_instance_of(ActionView::Base).to receive(:image_tag).and_return("")
    allow_any_instance_of(ApplicationHelper).to receive(:svg).and_return("")
    allow_any_instance_of(ApplicationHelper).to receive(:room_thumbnail_image).and_return("")
    allow_any_instance_of(ActionView::Base).to receive(:render).and_wrap_original do |method, *args, **kwargs, &block|
      partial = args.first
      next "" if partial == "layouts/header" || partial == "layouts/footer"

      method.call(*args, **kwargs, &block)
    end
    allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
      next unless controller.current_user

      controller.current_user.membership = ["mi-classrooms-non-admin-staging"]
      controller.current_user.admin = false
    end
  end

  describe "GET /rooms" do
    it "allows an authenticated viewer to load the rooms index" do
      get rooms_path

      expect_successful_response
      expect(response.body).to include("Classrooms")
      expect(response.body).to include("Undergraduate Science Building")
      expect(response.body).not_to include("Admin panel")
    end

    it "filters rooms by classroom name for an authenticated viewer" do
      get rooms_path, params: {classroom_name: "USB 101"}

      expect_successful_response
      expect(response.body).to include("1 Room")
      expect(response.body).to include("USB101")
      expect(response.body).to include("Classroom: *USB 101*")
      expect(response.body).not_to include("USB202")
    end

    it "filters rooms by minimum instructional seating" do
      get rooms_path, params: {min_capacity: "50"}

      expect_successful_response
      expect(response.body).to include("USB202")
      expect(response.body).not_to include("USB101")
    end
  end

  describe "POST /rooms/:id/toggle_visible" do
    it "rejects viewers" do
      post toggle_visible_room_path(matching_room)

      expect(response).to redirect_to(about_path)
      expect(matching_room.reload.visible).to be(true)
    end

    context "when signed in as an admin" do
      before do
        matching_room.update!(visible: true)
        allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
          next unless controller.current_user

          controller.current_user.membership = ["mi-classrooms-admin-staging"]
          controller.current_user.admin = true
        end
      end

      it "toggles room visibility" do
        post toggle_visible_room_path(matching_room)

        expect(response).to redirect_to(room_path(matching_room))
        expect(flash[:notice]).to eq("Room is now inactive.")
        expect(matching_room.reload.visible).to be(false)
      end

      it "supports the legacy toggle_visibile URL" do
        post toggle_visibile_path(matching_room)

        expect(response).to redirect_to(room_path(matching_room))
        expect(matching_room.reload.visible).to be(false)
      end
    end
  end

  describe "GET /rooms/:id" do
    it "allows an authenticated viewer to see an active room" do
      get room_path(matching_room)

      expect_successful_response
      expect(response.body).to include("USB101")
      expect(response.body).to include("Instructional seating count:")
      expect(response.body).not_to include(edit_room_path(matching_room))
    end

    it "redirects an authenticated viewer away from inactive rooms" do
      matching_room.update!(visible: false)

      get room_path(matching_room)

      expect(response).to redirect_to(rooms_path)
      expect(flash[:notice]).to eq("Room is inactive")
    end

    it "returns the room json payload for an authenticated viewer" do
      get room_path(matching_room, format: :json)

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["rmrecnbr"]).to eq(matching_room.rmrecnbr)
      expect(json["room_number"]).to eq("101")
      expect(json["rmtyp_description"]).to eq("Classroom")
      expect(json["url"]).to eq(room_url(matching_room, format: :json))
    end
  end

  def expect_successful_response
    raise server_error_summary if response.server_error?

    expect(response).to have_http_status(:ok)
  end

  def server_error_summary
    response.body
      .gsub(/<script.*?<\/script>/m, "")
      .gsub(/<style.*?<\/style>/m, "")
      .gsub(/<[^>]+>/, " ")
      .squish
      .first(2_000)
  end
end
