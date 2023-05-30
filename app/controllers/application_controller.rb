class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_in_group
  before_action :set_membership
  after_action :verify_authorized, unless: :devise_controller?

  def delete_file_attachment
    @delete_file = ActiveStorage::Attachment.find(params[:id])
    authorize @delete_file
    @delete_file.purge
    redirect_back(fallback_location: rooms_path)
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
    # create array of room cahracteristics to use in filters
    characteristics_all = RoomCharacteristic.all.pluck(:chrstc_descr, :chrstc_descrshort).uniq
    characteristics_all.delete_if {|x| x.include?(nil)}
    characteristics_all.sort
    @all_characteristics_array = {}
    category_prev = ""
    other = {}
    team = {}
    characteristics_all.each do |item|
      next if item[0]["Assisted Listening"]
      next if item[0]["Blue Ray Disc"]
      next if item[0]["16mm Film(Movies)"]
      filter_key = item[1]
      if item[0][":"]
        category = item[0].slice(0, item[0].index(': '))
        next if category["Wheelchair"]
        # value = item[0].sub(/.*?:/, '').lstrip
        value = item[0].partition(': ').last
        if value.downcase["team"]
          team.merge!(filter_key => value)
        else 
          if category == category_prev
            @all_characteristics_array[category].merge!(filter_key => value)
          else 
            @all_characteristics_array.merge!(category => { filter_key => value })
          end
          category_prev = category
        end
      else
        other.merge!(filter_key => item[0])
      end
    end
    @all_characteristics_array.merge!("Team Based Learning" => team)
    @all_characteristics_array.merge!("Other" => other)

  end

end
