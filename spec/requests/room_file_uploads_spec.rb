# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Room file uploads", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user) }
  let!(:building) do
    create(
      :building,
      bldrecnbr: 4_000_201,
      name: "Upload Test Building",
      address: "1 Main St",
      city: "Ann Arbor",
      zip: "48109",
      visible: true
    )
  end
  let!(:room) do
    create(
      :room,
      building_bldrecnbr: building.bldrecnbr,
      rmrecnbr: 4_000_301,
      room_number: "101",
      facility_code_heprod: "UP101",
      rmtyp_description: "Classroom",
      instructional_seating_count: 40,
      visible: true
    )
  end

  before do
    sign_in admin, scope: :user

    allow(ProcessThumbnailJob).to receive(:perform_later)
    allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
      next unless controller.current_user

      controller.current_user.membership = ["mi-classrooms-admin-staging"]
      controller.current_user.admin = true
    end
  end

  def oversized_pdf_upload
    path = Rails.root.join("tmp", "rspec_oversized_room_layout_#{Process.pid}_#{rand(1_000_000)}.pdf")
    File.binwrite(path, "0" * (10.megabyte + 1))
    Rack::Test::UploadedFile.new(path.to_s, "application/pdf")
  end

  def within_limit_pdf_upload
    path = Rails.root.join("tmp", "rspec_small_room_layout_#{Process.pid}_#{rand(1_000_000)}.pdf")
    File.binwrite(path, "0" * 1024)
    Rack::Test::UploadedFile.new(path.to_s, "application/pdf")
  end

  after do
    FileUtils.rm_f(Dir[Rails.root.join("tmp/rspec_*_room_layout_*.pdf")])
  end

  describe "PATCH /rooms/:id.json with room_layout" do
    it "returns 422 and JSON errors when the file exceeds 10 MB" do
      patch room_path(room, format: :json),
        params: {room: {visible: "1", room_layout: oversized_pdf_upload}},
        headers: {"Accept" => "application/json"}

      expect(response).to have_http_status(422)
      body = JSON.parse(response.body)
      messages = body["room_layout"] || body[:room_layout]
      expect(messages.join(" ")).to include("must be 10 MB or smaller")
      expect(room.reload.room_layout).not_to be_attached
    end
  end

  describe "PATCH /rooms/:id with room_layout (HTML redirect)" do
    before do
      allow_any_instance_of(ActionView::Base).to receive(:stylesheet_link_tag).and_return("")
      allow_any_instance_of(Importmap::ImportmapTagsHelper).to receive(:javascript_importmap_tags).and_return("")
    end

    it "accepts a small PDF under the limit" do
      patch room_path(room),
        params: {
          room: {visible: "1", room_layout: within_limit_pdf_upload},
          commit: "Save Room"
        },
        headers: {"Accept" => "text/html"}

      expect(response).to redirect_to(room_path(room))
      expect(flash[:notice]).to eq("Room was successfully updated.")
      expect(room.reload.room_layout).to be_attached
    end
  end
end
