class PagesController < ApplicationController
  
  def about
    authorize :page
  end

  def index
    redirect_to rooms_path if current_user
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
