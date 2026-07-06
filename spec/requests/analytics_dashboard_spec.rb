require "rails_helper"

RSpec.describe "Analytics Dashboard", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin)  { create(:user) }
  let(:viewer) { create(:user) }

  before do
    stub_request_layout_partials
  end

  describe "GET /analytics" do
    context "as an admin" do
      before do
        sign_in admin, scope: :user
        stub_membership(admin: true)
      end

      it "returns 200" do
        get analytics_dashboard_path
        raise response.body if response.server_error?
        expect(response).to have_http_status(:ok)
      end

      it "includes the page title" do
        get analytics_dashboard_path
        expect(response.body).to include("Analytics Dashboard")
      end

      it "accepts a range parameter" do
        get analytics_dashboard_path, params: {range: "30d"}
        expect(response).to have_http_status(:ok)
      end

      it "defaults to 7d for an unrecognised range" do
        get analytics_dashboard_path, params: {range: "bogus"}
        expect(response).to have_http_status(:ok)
      end

      it "scopes hourly chart data to the selected range" do
        now = Time.current.beginning_of_hour
        (0..240).step(24) do |hours_ago|
          AnalyticsHourlyRollup.create!(
            period_start: now - hours_ago.hours,
            controller_name: "rooms",
            action_name: "index",
            total_views: 1,
            unique_sessions: 1,
            unique_users: 1,
            authenticated_views: 0
          )
        end

        get analytics_dashboard_path, params: {range: "24h"}
        doc24 = Nokogiri::HTML(response.body)
        labels24 = JSON.parse(doc24.at("[data-analytics-chart-labels-value]")["data-analytics-chart-labels-value"])

        get analytics_dashboard_path, params: {range: "7d"}
        doc7 = Nokogiri::HTML(response.body)
        labels7 = JSON.parse(doc7.at("[data-analytics-chart-labels-value]")["data-analytics-chart-labels-value"])

        expect(labels24.length).to be < labels7.length
      end

      it "reflects the selected range in the page and disables caching" do
        get analytics_dashboard_path, params: {range: "24h"}

        expect(response.body).to include("last 24 hours")
        expect(response.body).to include('data-range="24h"')
        expect(response.headers["Cache-Control"]).to include("no-store")
      end
    end

    context "as a non-admin user" do
      before do
        sign_in viewer, scope: :user
        stub_membership(admin: false)
      end

      it "redirects to about page" do
        get analytics_dashboard_path
        expect(response).to redirect_to(about_path)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        get analytics_dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
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
