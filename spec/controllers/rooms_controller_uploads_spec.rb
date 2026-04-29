# frozen_string_literal: true

require "rails_helper"

RSpec.describe RoomsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin) { create(:user) }
  let!(:building) { create(:building, bldrecnbr: 4_000_401, zip: "48109", visible: true) }
  let!(:room) do
    create(
      :room,
      building_bldrecnbr: building.bldrecnbr,
      rmrecnbr: 4_000_501,
      rmtyp_description: "Classroom",
      facility_code_heprod: "UC501",
      instructional_seating_count: 30,
      visible: true
    )
  end

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in admin, scope: :user
    allow(ProcessThumbnailJob).to receive(:perform_later)
    allow_any_instance_of(ApplicationController).to receive(:set_membership) do |c|
      next unless c.respond_to?(:current_user) && c.current_user

      c.current_user.membership = ["mi-classrooms-admin-staging"]
      c.current_user.admin = true
    end
  end

  def oversized_pdf_upload
    path = Rails.root.join("tmp", "rspec_oversized_ctrl_#{Process.pid}_#{rand(1_000_000)}.pdf")
    File.binwrite(path, "0" * (10.megabyte + 1))
    Rack::Test::UploadedFile.new(path.to_s, "application/pdf")
  end

  after do
    FileUtils.rm_f(Dir[Rails.root.join("tmp/rspec_oversized_ctrl_*.pdf")])
  end

  describe "PATCH #update" do
    it "sets flash.now alert and returns 422 when room_layout exceeds 10 MB" do
      patch :update, params: {
        id: room.rmrecnbr,
        room: {visible: "1", room_layout: oversized_pdf_upload},
        commit: "Save Room"
      }

      expect(response).to have_http_status(422)
      expect(flash.now[:alert]).to include("Room layout must be 10 MB or smaller")
    end
  end
end
