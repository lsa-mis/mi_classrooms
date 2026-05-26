module RequestLayoutStubs
  def stub_request_layout_assets
    allow_any_instance_of(ActionView::Base).to receive(:stylesheet_link_tag).and_return("")
    allow_any_instance_of(Importmap::ImportmapTagsHelper).to receive(:javascript_importmap_tags).and_return("")
    allow_any_instance_of(ActionView::Base).to receive(:image_tag).and_return("")
    allow_any_instance_of(ApplicationHelper).to receive(:svg).and_return("")
    allow_any_instance_of(ApplicationHelper).to receive(:room_thumbnail_image).and_return("")

    %i[lsa_tdx_feedback_css lsa_tdx_feedback_modal lsa_tdx_feedback_js].each do |helper|
      allow_any_instance_of(ActionView::Base).to receive(helper).and_return(ActiveSupport::SafeBuffer.new(""))
    end

    allow(Sentry).to receive(:get_trace_propagation_meta).and_return("")
  end

  def stub_request_layout_partials
    stub_request_layout_assets
    allow_any_instance_of(ActionView::Base).to receive(:render).and_wrap_original do |method, *args, **kwargs, &block|
      partial = args.first
      next "" if partial == "layouts/header" || partial == "layouts/footer"

      method.call(*args, **kwargs, &block)
    end
  end
end

RSpec.configure do |config|
  config.include RequestLayoutStubs, type: :request

  config.before(:each, type: :request) do
    stub_request_layout_assets
  end
end
