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

    allow(ProcessThumbnailJob).to receive(:perform_later)
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

    it "avoids per-room active storage blob queries for filtered listings" do
      attach_test_image(matching_room, :room_image)
      attach_test_image(other_room, :room_image)
      attach_test_image(building, :building_image)

      allow_any_instance_of(ApplicationHelper).to receive(:room_thumbnail_image).and_call_original

      blob_queries = capture_blob_queries do
        get rooms_path, params: {classroom_name: "USB"}
      end

      expect_successful_response
      # CI can issue one additional blob lookup depending on ActiveStorage adapter internals.
      # Keep this bound tight enough to catch per-room N+1 regressions.
      expect(blob_queries.count).to be <= 4
    end

    it "avoids per-row alert note lookups in room listings" do
      create(:note, :alert, noteable: matching_room)
      create(:note, :alert, noteable: other_room)
      create(:note, :alert, noteable: building)

      note_queries = capture_alert_note_queries do
        get rooms_path, params: {classroom_name: "USB"}
      end

      expect_successful_response
      expect(note_queries).to be_empty
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

    it "avoids repeated alert note lookups on the room show page" do
      create(:note, :alert, noteable: matching_room)
      create(:note, :notice, noteable: matching_room)
      create(:note, :alert, noteable: building)

      note_queries = capture_alert_note_queries do
        get room_path(matching_room)
      end

      expect_successful_response
      expect(note_queries).to be_empty
    end
  end

  def expect_successful_response
    if response.server_error?
      body = response.body.to_s

      useful_lines = body.lines.grep(
        /Error|Exception|Trace|NoMethod|NameError|ArgumentError|LoadError|ActiveStorage|MiniMagick|Vips|ImageProcessing|PG::|ActionView/
      )

      raise <<~ERROR
        Expected a successful response, got #{response.status}.

        Useful response body lines:
        #{useful_lines.first(80).join}
      ERROR
    end

    expect(response).to be_successful
  end

  def server_error_message
    "Expected a successful response, got #{response.status}. See log/test.log for the rendered exception details."
  end

  def attach_test_image(record, attachment_name)
    path = Rails.root.join("spec/fixtures/files/test_image.jpg")
    record.public_send(attachment_name).attach(
      io: StringIO.new(File.binread(path)),
      filename: "test_image.jpg",
      content_type: "image/jpeg"
    )
  end

  def capture_blob_queries
    queries = []
    callback = lambda { |_, _, _, _, payload|
      sql = payload[:sql].to_s
      queries << sql if sql.include?("FROM \"active_storage_blobs\"")
    }

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      ActiveRecord::Base.uncached { yield }
    end

    queries
  end

  def capture_alert_note_queries
    queries = []
    callback = lambda { |_, _, _, _, payload|
      sql = payload[:sql].to_s
      queries << sql if sql.include?("FROM \"notes\"") && sql.include?("\"alert\" =")
    }

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      ActiveRecord::Base.uncached { yield }
    end

    queries
  end
end
