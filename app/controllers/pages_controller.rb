class PagesController < ApplicationController
  
  def about
    authorize :page

  end

  def index
    @index_page_announcement = Announcement.find_by(location: "home_page")
    # redirect_to rooms_path if current_user
    if current_user
      redirect_to rooms_path unless current_user.admin
    end
    skip_policy_scope
  end

  def contact
    authorize :page
  end

  def privacy
    authorize :page
  end

  def project_status
    authorize :page
  end
end
