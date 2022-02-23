class ClassroomsController < ApplicationController
  before_action :authenticate_user!

  def index
    skip_policy_scope

    redirect_to rooms_path + "?school_or_college_name=College+of+Lit%2C+Science+%26+Arts"
  end

  def show
    authorize :classroom

    uri_substring = URI.split(request.url)[5]
    room_from_url = uri_substring.split('/')[2]
    redirect_to room_path(Room.find_by(facility_code_heprod: room_from_url))
  end
end
