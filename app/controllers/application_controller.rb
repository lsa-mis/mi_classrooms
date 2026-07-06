class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization
  include Trackable

  rescue_from Pundit::NotAuthorizedError, with: :user_not_in_group
  before_action :set_membership
  after_action :verify_authorized, unless: :devise_controller?

  helper_method :room_characteristic_definitions

  def delete_file_attachment
    @delete_file = ActiveStorage::Attachment.find(params[:id])
    authorize @delete_file
    record = @delete_file.record
    @delete_file.purge
    redirect_to attachment_redirect_path(record), notice: "File removed."
  rescue ActiveRecord::RecordNotFound
    redirect_back(fallback_location: rooms_path)
  rescue ActionController::UrlGenerationError
    redirect_back(fallback_location: rooms_path, notice: "File removed.")
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

  def attachment_redirect_path(record)
    polymorphic_path(record)
  rescue NoMethodError, ActionController::UrlGenerationError
    parent = attachment_redirect_parent(record)
    return polymorphic_path([parent, record]) if parent

    rooms_path
  end

  def attachment_redirect_parent(record)
    record.building if record.respond_to?(:building) && record.building.present?
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

  def room_characteristic_definitions
    @room_characteristic_definitions ||= Rails.cache.fetch(room_characteristic_definitions_cache_key, expires_in: 12.hours) do
      RoomCharacteristic
        .where.not(chrstc_descrshort: nil, chrstc_desc254: nil)
        .pluck(:chrstc_descrshort, :chrstc_desc254)
        .uniq
        .to_h
    end
  end

  def room_characteristic_definitions_cache_key
    [
      "v1",
      "room_characteristic_definitions",
      RoomCharacteristic.maximum(:updated_at),
      RoomCharacteristic.count
    ]
  end

  def set_characteristics_array
    cache_key = [
      "v2",
      "room_characteristics_filter_hash",
      RoomCharacteristic.maximum(:updated_at),
      RoomCharacteristic.count,
      Room.maximum(:updated_at),
      Room.count
    ]
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
