class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_in_group
  before_action :set_membership
  after_action :verify_authorized, unless: :devise_controller?

  def delete_file_attachment
    @delete_file = ActiveStorage::Attachment.find(params[:id])
    authorize @delete_file
    @delete_file.purge
    redirect_back(fallback_location: rooms_path)
  end

  def set_redirection_url
    return if user_signed_in?
    return unless request.get?
    return unless request.format.html?

    store_location_for(:user, request.fullpath)
  end

  private

  def user_not_authorized
    flash[:alert] = "Please sign in to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def user_not_in_group
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to about_path
  end

  def set_membership
    if user_signed_in?
      current_user.membership = session[:user_memberships]
      current_user.admin = session[:user_admin]
    else
      new_user_session_path
    end
  end

  def set_characteristics_array
    max_updated = RoomCharacteristic.maximum(:updated_at)
    cache_key = ["v1", "room_characteristics_filter_hash", max_updated]
    @all_characteristics_array = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      build_room_characteristics_filter_hash
    end
  end

  def build_room_characteristics_filter_hash
    # create array of room characteristics to use in filters
    characteristics_all = RoomCharacteristic.all.pluck(:chrstc_descr, :chrstc_descrshort).uniq
    characteristics_all.delete_if { |x| x.include?(nil) }
    characteristics_all = characteristics_all.sort
    grouped = {}
    category_prev = ""
    other = {}
    team = {}
    characteristics_all.each do |item|
      next if item[0]["Assisted Listening"]
      next if item[0]["Blue Ray Disc"]
      next if item[0]["16mm Film(Movies)"]
      filter_key = item[1]
      if item[0][":"]
        category = item[0].slice(0, item[0].index(": "))
        next if category["Wheelchair"]
        value = item[0].partition(": ").last
        if value.downcase["team"]
          team.merge!(filter_key => value)
        else
          if category == category_prev
            grouped[category][filter_key] = value
          else
            grouped[category] = {filter_key => value}
          end
          category_prev = category
        end
      else
        other.merge!(filter_key => item[0])
      end
    end
    grouped["Team Based Learning"] = team
    grouped["Other"] = other
    grouped
  end
end
