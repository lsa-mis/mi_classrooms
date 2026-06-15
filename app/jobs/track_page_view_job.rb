class TrackPageViewJob < ApplicationJob
  queue_as :analytics

  # All arguments are plain scalars so the job is safe to retry and replay.
  def perform(session_token:, user_id: nil, controller_name:, action_name:, path:,
    referrer_host: nil, device_type: nil, http_status: nil, duration_ms: nil, occurred_at:)
    PageView.create!(
      session_token: session_token,
      user_id: user_id,
      controller_name: controller_name,
      action_name: action_name,
      path: path,
      referrer_host: referrer_host,
      device_type: device_type,
      http_status: http_status,
      duration_ms: duration_ms,
      occurred_at: Time.zone.parse(occurred_at.to_s)
    )
  end
end
