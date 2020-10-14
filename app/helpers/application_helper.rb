module ApplicationHelper
  include Pagy::Frontend

  # Returns the full title on a per-page basis.
  def page_title
    base_title = (t :site_name)
    if @page_title.nil?
      "#{params[:controller].capitalize} | " + base_title
    else
      "#{@page_title} | #{base_title}"
    end
  end


  def flash_class(level)
    case level
    when :notice  then "alert alert-info"
    when :success then "alert alert-success"
    when :error   then "alert alert-error"
    when :alert   then "alert alert-error"
    end
  end
end