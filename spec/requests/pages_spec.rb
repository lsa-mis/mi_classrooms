require "rails_helper"

RSpec.describe "Pages", type: :request do
  include Devise::Test::IntegrationHelpers

  def stub_layout_dependencies
    allow_any_instance_of(ActionView::Base).to receive(:stylesheet_link_tag).and_return("")
    allow_any_instance_of(Importmap::ImportmapTagsHelper).to receive(:javascript_importmap_tags).and_return("")
    allow_any_instance_of(ActionView::Base).to receive(:image_tag).and_return("")
    allow_any_instance_of(ApplicationHelper).to receive(:svg).and_return("")
    allow_any_instance_of(ApplicationHelper).to receive(:room_thumbnail_image).and_return("")
    allow_any_instance_of(ActionView::Base).to receive(:render).and_wrap_original do |method, *args, **kwargs, &block|
      partial = args.first
      next "" if partial == "layouts/header" || partial == "layouts/footer"

      method.call(*args, **kwargs, &block)
    end
  end

  def force_membership(admin:)
    allow_any_instance_of(ApplicationController).to receive(:set_membership) do |controller|
      next unless controller.current_user

      controller.current_user.membership = [admin ? "mi-classrooms-admin-staging" : "mi-classrooms-non-admin-staging"]
      controller.current_user.admin = admin
    end
  end

  let(:user) { create(:user) }

  before do
    stub_layout_dependencies
  end

  describe "GET /" do
    it "loads home for guests" do
      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "redirects signed-in viewers to rooms" do
      sign_in user, scope: :user
      force_membership(admin: false)

      get root_path

      expect(response).to redirect_to(rooms_path)
    end
  end

  describe "GET /about" do
    it "loads the about page" do
      get about_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /room_filters_glossary" do
    before do
      building = create(:building)
      room = create(:room, building_bldrecnbr: building.bldrecnbr)
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc_descrshort: "Projector", chrstc_desc254: "Projection display")
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc_descrshort: "Whiteboard", chrstc_desc254: "Wall whiteboard")
    end

    it "requires authentication" do
      get room_filters_glossary_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "allows authenticated users" do
      sign_in user, scope: :user
      force_membership(admin: false)

      get room_filters_glossary_path

      expect(response).to have_http_status(:ok)
    end
  end
end
