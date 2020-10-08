module FlashErrorsHelper
  def flash_class(level)
    case level
    when :danger then "alert alert-danger"
    when :error   then "alert alert-error"
    when :notice  then "alert alert-notice"
    when :success then "alert alert-success"
    when :warning then "alert alert-warning"
    end
  end

  SEVERITY_ICONS = {notice: "info-circle", danger: "exclamation-triangle", error: "exclamation", success: "check-circle", warning: "bullhorn"}

  def severity_icon(severity)
    SEVERITY_ICONS[severity]
  end
end
