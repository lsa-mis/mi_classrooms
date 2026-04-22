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
      get delete_file_path(attachment.id)

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
      get delete_file_path(attachment.id)

      expect(response).to redirect_to(rooms_path)
      expect(room.reload.room_image).not_to be_attached
    end
  end
end
