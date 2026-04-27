require "rails_helper"

RSpec.describe "API update logs", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user) }
  let(:viewer) { create(:user) }
  let!(:api_update_log) do
    ApiUpdateLog.create!(
      status: "success",
      result: <<~TEXT
        Time report:
        Update campus list Time: 1.2 seconds

        Structured report:
        {
          "status": "success",
          "started_at": "2026-04-27T08:00:00-04:00",
          "finished_at": "2026-04-27T08:10:00-04:00",
          "duration_seconds": 600.0,
          "phases": [
            {
              "phase": "Update campus list",
              "status": "success",
              "duration_seconds": 1.2,
              "counters": {
                "updated": 3
              },
              "warnings": [],
              "errors": []
            }
          ]
        }
      TEXT
    )
  end

  before do
    allow_any_instance_of(ActionView::Base).to receive(:stylesheet_link_tag).and_return("")
    allow_any_instance_of(Importmap::ImportmapTagsHelper).to receive(:javascript_importmap_tags).and_return("")
  end

  describe "GET /api_update_logs" do
    it "shows the summary to admins" do
      sign_in admin, scope: :user
      stub_membership(admin: true)

      get api_update_logs_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("API Update Summary")
      expect(response.body).to include("Update campus list")
      expect(response.body).to include("Updated")
    end

    it "rejects non-admin users" do
      sign_in viewer, scope: :user
      stub_membership(admin: false)

      get api_update_logs_path

      expect(response).to redirect_to(about_path)
    end
  end

  describe "GET /api_update_logs/:id" do
    it "shows a run detail page to admins" do
      sign_in admin, scope: :user
      stub_membership(admin: true)

      get api_update_log_path(api_update_log)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Raw Saved Report")
      expect(response.body).to include("Structured report")
    end
  end

  private

  def stub_membership(admin:)
    allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
      next unless controller.current_user

      controller.current_user.membership = [admin ? "mi-classrooms-admin-staging" : "mi-classrooms-non-admin-staging"]
      controller.current_user.admin = admin
    end
  end
end
