require "rails_helper"

RSpec.describe "Announcements", type: :request do
  include Devise::Test::IntegrationHelpers

  def force_membership(admin:)
    allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
      next unless controller.current_user

      controller.current_user.membership = [admin ? "mi-classrooms-admin-staging" : "mi-classrooms-non-admin-staging"]
      controller.current_user.admin = admin
    end
  end

  let(:user) { create(:user) }
  describe "authentication" do
    it "requires sign in" do
      get announcements_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "admin access" do
    let!(:announcement) { Announcement.create!(location: "home_page", content: "Original content") }

    before do
      sign_in user, scope: :user
      force_membership(admin: true)
      stub_request_layout_partials
    end

    it "loads index" do
      get announcements_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Announcements")
    end

    it "loads show" do
      get announcement_path(announcement)

      expect(response).to have_http_status(:not_acceptable)
    end

    it "loads new with a preselected location" do
      get new_announcement_path, params: {location: "about_page"}

      expect(response).to have_http_status(:ok)
    end

    it "creates a valid announcement" do
      expect {
        post announcements_path, params: {
          announcement: {
            location: "about_page",
            content: "New message"
          }
        }
      }.to change(Announcement, :count).by(1)

      expect(response).to redirect_to(announcements_path)
      expect(flash[:notice]).to eq("Announcement was successfully created.")
    end

    it "rejects invalid creates" do
      expect {
        post announcements_path, params: {
          announcement: {
            location: "",
            content: "Invalid"
          }
        }
      }.not_to change(Announcement, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "updates an announcement" do
      patch announcement_path(announcement), params: {
        announcement: {
          location: "about_page",
          content: "Updated content"
        }
      }

      expect(response).to redirect_to(announcements_path)
      expect(flash[:notice]).to eq("Announcement was successfully updated.")
      expect(announcement.reload.location).to eq("about_page")
    end

    it "rejects invalid updates" do
      patch announcement_path(announcement), params: {
        announcement: {
          location: "invalid_location"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(announcement.reload.location).to eq("home_page")
    end

    it "deletes an announcement" do
      expect {
        delete announcement_path(announcement)
      }.to change(Announcement, :count).by(-1)

      expect(response).to redirect_to(announcements_path)
      expect(flash[:notice]).to eq("Announcement was successfully deleted.")
    end
  end

  describe "viewer access" do
    let!(:announcement) { Announcement.create!(location: "home_page", content: "Visible content") }

    before do
      sign_in user, scope: :user
      force_membership(admin: false)
      stub_request_layout_partials
    end

    it "denies index" do
      get announcements_path

      expect(response).to redirect_to(about_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "denies show" do
      get announcement_path(announcement)

      expect(response).to redirect_to(about_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "denies create" do
      post announcements_path, params: {announcement: {location: "about_page", content: "No access"}}

      expect(response).to redirect_to(about_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end
  end
end
