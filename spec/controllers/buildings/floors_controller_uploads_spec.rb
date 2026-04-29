# frozen_string_literal: true

require "rails_helper"

RSpec.describe Buildings::FloorsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin) { create(:user) }
  let!(:building) { create(:building, bldrecnbr: 4_000_601, zip: "48109", visible: true) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in admin, scope: :user
    allow_any_instance_of(ApplicationController).to receive(:set_membership) do |c|
      next unless c.respond_to?(:current_user) && c.current_user

      c.current_user.membership = ["mi-classrooms-admin-staging"]
      c.current_user.admin = true
    end
  end

  def oversized_pdf_upload
    path = Rails.root.join("tmp", "rspec_oversized_floor_#{Process.pid}_#{rand(1_000_000)}.pdf")
    File.binwrite(path, "0" * (10.megabyte + 1))
    Rack::Test::UploadedFile.new(path.to_s, "application/pdf")
  end

  after do
    FileUtils.rm_f(Dir[Rails.root.join("tmp/rspec_oversized_floor_*.pdf")])
  end

  describe "POST #create" do
    it "redirects with an alert when floor_plan exceeds 10 MB" do
      post :create, params: {
        building_id: building.bldrecnbr,
        floor: {floor: "99", floor_plan: oversized_pdf_upload},
        commit: "Save"
      }

      expect(response).to redirect_to(building_path(building))
      expect(flash[:alert]).to include("Floor plan is too big")
    end
  end
end
