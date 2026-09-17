require "rails_helper"

RSpec.describe "Notes", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let!(:building) { create(:building, bldrecnbr: 7_000_101, visible: true) }
  let!(:room) do
    create(
      :room,
      building_bldrecnbr: building.bldrecnbr,
      rmrecnbr: 1_500_101,
      rmtyp_description: "Classroom",
      facility_code_heprod: "NOTE101",
      instructional_seating_count: 65,
      visible: true
    )
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

    it "rejects room note creation" do
      expect do
        post room_notes_path(room), params: {note: {body: "Viewer note", alert: false}}
      end.not_to change(Note, :count)

      expect(response).to redirect_to(about_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "rejects building note creation" do
      expect do
        post building_notes_path(building), params: {note: {body: "Viewer building note", alert: false}}
      end.not_to change(Note, :count)

      expect(response).to redirect_to(about_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "rejects note deletion" do
      note = create(:note, noteable: room, user: user)

      expect do
        delete note_path(note)
      end.not_to change(Note, :count)

      expect(response).to redirect_to(about_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
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

    it "creates a room note" do
      expect do
        post room_notes_path(room), params: {note: {body: "Admin room note", alert: false}}
      end.to change(Note, :count).by(1)

      expect(response).to redirect_to(room_path(room))
      expect(Note.last.body.to_plain_text).to eq("Admin room note")
    end

    it "creates a building note" do
      expect do
        post building_notes_path(building), params: {note: {body: "Admin building note", alert: true}}
      end.to change(Note, :count).by(1)

      expect(response).to redirect_to(building_path(building))
      expect(Note.last.noteable).to eq(building)
      expect(Note.last.alert).to be(true)
    end

    it "deletes an existing note" do
      note = create(:note, noteable: room, user: user)

      expect do
        delete note_path(note)
      end.to change(Note, :count).by(-1)

      expect(response).to redirect_to(room_path(room))
    end

    it "re-renders the turbo note form with errors when body is blank" do
      expect do
        post room_notes_path(room),
          params: {note: {body: "", alert: false}},
          as: :turbo_stream
      end.not_to change(Note, :count)

      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include('turbo-stream action="replace"')
      expect(response.body).to include("alert-danger")
      expect(response.body).to include("Body can&#39;t be blank")
      expect(response.body).to include('name="note[body]"')
    end

    it "replaces the turbo note form with a blank form after a successful create" do
      expect do
        post room_notes_path(room),
          params: {note: {body: "Turbo room note", alert: false}},
          as: :turbo_stream
      end.to change(Note, :count).by(1)

      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include('turbo-stream action="replace"')
      expect(response.body).not_to include("alert-danger")
      expect(Note.last.body.to_plain_text).to eq("Turbo room note")
    end
  end
end
