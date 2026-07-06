require "rails_helper"

RSpec.describe "Attachment deletions", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let!(:building) { create(:building, bldrecnbr: 6_000_101, visible: true) }
  let!(:room) do
    create(
      :room,
      building_bldrecnbr: building.bldrecnbr,
      rmrecnbr: 1_400_101,
      rmtyp_description: "Classroom",
      facility_code_heprod: "ATT101",
      instructional_seating_count: 55,
      visible: true
    )
  end
  let!(:attachment) do
    room.room_image.attach(
      io: StringIO.new("fake image"),
      filename: "room.png",
      content_type: "image/png"
    )
    room.room_image.attachment
  end

  before do
    sign_in user, scope: :user
  end

  context "when signed in as a viewer" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
        next unless controller.current_user

        controller.current_user.membership = ["mi-classrooms-non-admin-staging"]
        controller.current_user.admin = false
      end
    end

    it "rejects attachment deletion" do
      delete delete_file_path(attachment.id)

      expect(response).to redirect_to(about_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      expect(room.reload.room_image).to be_attached
    end
  end

  context "when signed in as an admin" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
        next unless controller.current_user

        controller.current_user.membership = ["mi-classrooms-admin-staging"]
        controller.current_user.admin = true
      end
    end

    it "purges the attachment" do
      delete delete_file_path(attachment.id)

      expect(response).to redirect_to(room_path(room))
      expect(room.reload.room_image).not_to be_attached
    end

    it "purges a building image and redirects to the building page" do
      building.building_image.attach(
        io: StringIO.new("fake image"),
        filename: "building.png",
        content_type: "image/png"
      )
      building_attachment = building.building_image.attachment

      delete delete_file_path(building_attachment.id)

      expect(response).to redirect_to(building_path(building))
      expect(building.reload.building_image).not_to be_attached
    end

    it "purges a floor plan and redirects to the nested floor page" do
      floor = create(:floor, building_bldrecnbr: building.bldrecnbr)
      floor_attachment = floor.floor_plan.attachment

      delete delete_file_path(floor_attachment.id)

      expect(response).to redirect_to(building_floor_path(building, floor))
      expect(floor.reload.floor_plan).not_to be_attached
    end
  end
end
