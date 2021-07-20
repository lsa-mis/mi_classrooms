module FlashErrorsHelper
  def flash_class(level)
    case level
    when :danger then "alert-danger"
    when :error   then "alert-error"
    when :notice  then "alert-notice"
    when :success then "alert-success"
    when :warning then "alert-warning"
    end
  end

  SEVERITY_ICONS = {
    danger: "shield-exclamation",
    error: "triangle-exclamation", 
    notice: "circle-check", 
    success: "thumbs-up", 
    warning: "siren-on"}

  def severity_icon(severity)
    SEVERITY_ICONS[severity]
  end
end
