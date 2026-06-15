module Trackable
  extend ActiveSupport::Concern

  included do
    before_action :set_request_start_time
    after_action :track_page_view, unless: :skip_tracking?
  end

  private

  def set_request_start_time
    @request_start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def track_page_view
    TrackPageViewJob.perform_later(
      session_token: hashed_session_token,
      user_id: current_user&.id,
      controller_name: params[:controller].to_s,
      action_name: params[:action].to_s,
      path: sanitized_request_path,
      referrer_host: extract_referrer_host,
      device_type: classify_device_type,
      http_status: response.status,
      duration_ms: elapsed_ms,
      occurred_at: Time.current.iso8601(6)
    )
  rescue => e
    Rails.logger.error("Trackable#track_page_view failed: #{e.class} #{e.message}")
  end

  def hashed_session_token
    Digest::SHA256.hexdigest(request.session.id.to_s)[0, 32]
  end

  # Replace all numeric path segments with :id to avoid storing PII in paths.
  def sanitized_request_path
    request.path.gsub(%r{/\d+}, "/:id").first(500)
  end

  def extract_referrer_host
    URI.parse(request.referrer.to_s).host
  rescue URI::InvalidURIError
    nil
  end

  def classify_device_type
    ua = request.user_agent.to_s.downcase
    return "bot" if ua.match?(/bot|crawl|slurp|spider|mediapartners|headless/)
    return "mobile" if ua.match?(/mobile|android|iphone|ipad|ipod/)
    "desktop"
  end

  def elapsed_ms
    return nil if @request_start_time.nil?
    ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - @request_start_time) * 1000).to_i
  end

  def skip_tracking?
    return true if devise_controller?
    return true if classify_device_type == "bot"
    return true if request.path.start_with?("/rails/", "/active_storage/", "/up", "/jobs", "/lsa_tdx_feedback", "/letter_opener")
    return true unless request.format.html?
    false
  end
end
