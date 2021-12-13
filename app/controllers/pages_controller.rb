class PagesController < ApplicationController
  
  def about
    authorize :page
  end

  def index
    @index_page_announcement = Announcement.find_by(location: "home_page")
    if current_user
      redirect_to rooms_path unless current_user.admin
    end
    skip_policy_scope
  end

end
