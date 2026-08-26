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
        labels24 = JSON.parse(doc24.at("#hourly-chart-24h")["data-analytics-chart-labels-value"])

        get analytics_dashboard_path, params: {range: "7d"}
        doc7 = Nokogiri::HTML(response.body)
        labels7 = JSON.parse(doc7.at("#hourly-chart-7d")["data-analytics-chart-labels-value"])

        expect(labels24.length).to be < labels7.length
      end

      it "reflects the selected range in the page and disables caching" do
        get analytics_dashboard_path, params: {range: "24h"}

        expect(response.body).to include("last 24 hours")
        expect(response.body).to include('data-range="24h"')
        expect(response.headers["Cache-Control"]).to include("no-store")
      end

      it "uses a Stimulus controller for range changes instead of inline handlers" do
        get analytics_dashboard_path

        expect(response.body).to include('data-controller="analytics-range"')
        expect(response.body).to include('data-action="change->analytics-range#change"')
        expect(response.body).not_to include("onchange=")
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

    context "with live page view data and no rollups" do
      before do
        sign_in admin, scope: :user
        stub_membership(admin: true)

        create(:page_view, session_token: "aaaa" * 8, controller_name: "rooms", action_name: "index", occurred_at: 1.hour.ago)
        create(:page_view, :authenticated, session_token: "bbbb" * 8, controller_name: "rooms", action_name: "index", occurred_at: 2.hours.ago)
        create(:page_view, session_token: "cccc" * 8, controller_name: "buildings", action_name: "show", occurred_at: 3.hours.ago)
      end

      it "renders live summary stats and top pages without waiting for rollups" do
        get analytics_dashboard_path, params: {range: "7d"}

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Total Views")
        expect(response.body).to include("rooms#index")
        expect(response.body).to include("buildings#show")
        expect(response.body).to include("Refresh Charts")
      end
    end
  end

  describe "POST /analytics/refresh" do
    context "as an admin" do
      before do
        sign_in admin, scope: :user
        stub_membership(admin: true)
        allow(AnalyticsRollupJob).to receive(:perform_now)
      end

      it "runs rollups for the selected range and redirects with a notice" do
        post analytics_dashboard_refresh_path, params: {range: "24h"}

        expect(AnalyticsRollupJob).to have_received(:perform_now).at_least(:once)
        expect(response).to redirect_to(analytics_dashboard_path(range: "24h"))
        follow_redirect!
        expect(response.body).to include("Charts refreshed")
      end

      it "defaults an unrecognized range to 7d when refreshing" do
        post analytics_dashboard_refresh_path, params: {range: "bogus"}

        expect(response).to redirect_to(analytics_dashboard_path(range: "7d"))
      end
    end

    context "as a non-admin user" do
      before do
        sign_in viewer, scope: :user
        stub_membership(admin: false)
      end

      it "does not allow refresh" do
        post analytics_dashboard_refresh_path, params: {range: "7d"}

        expect(response).to redirect_to(about_path)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        post analytics_dashboard_refresh_path, params: {range: "7d"}

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
