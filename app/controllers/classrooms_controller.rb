class ClassroomsController < ApplicationController
  # To handle redirects from legacy classroom links
  before_action :authenticate_user!

  def index
    skip_policy_scope

    redirect_to rooms_path + "?school_or_college_name=College+of+Lit%2C+Science+%26+Arts", alert: "You arrived here from an outdated link"
  end

  def show
    authorize :classroom

    uri_substring = URI.split(request.url)[5]
    room_from_url = uri_substring.split('/')[2]
    if converted_room = Room.find_by(facility_code_heprod: room_from_url)
      redirect_to room_path(Room.find_by(facility_code_heprod: room_from_url)), alert: "You arrived here from an outdated link"
    else 
      redirect_to rooms_path, alert: "You arrived here from an outdated link"
    end
  end
end
