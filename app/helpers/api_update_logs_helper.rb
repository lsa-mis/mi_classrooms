module ApiUpdateLogsHelper
  def format_api_update_time(value)
    return "Unknown" if value.blank?

    Time.zone.parse(value.to_s).strftime("%b %e, %Y %l:%M %p").squish
  rescue ArgumentError
    "Unknown"
  end
end
