class RoomsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_redirection_url
  before_action :authenticate_user!
  before_action :set_room_for_toggle_visible, only: [:toggle_visible]
  before_action :set_room, only: %i[show edit update destroy floor_plan]
  before_action :set_filters_list, only: [:index]
  before_action :set_characteristics_array, only: %i[index show]
  before_action :set_cache_headers, only: [:show]

  include ApplicationHelper

  def index
    @page_title = "Find a Room"
    @sorted = false
    buildings_ids = Room.classrooms.pluck(:building_bldrecnbr).uniq
    @buildings = params[:inactive_buildings].present? ?
      Building.includes(:notes, building_image_attachment: {blob: :variant_records}).where(bldrecnbr: buildings_ids, visible: false).order(:name) :
      Building.includes(:notes, building_image_attachment: {blob: :variant_records}).where(bldrecnbr: buildings_ids).order(:name)

    @rooms_page_announcement = Announcement.find_by(location: "find_a_room_page")
    @all_rooms_number = Room.classrooms.count
    @schools = Room.classrooms.pluck(:dept_group_description).uniq.compact.sort
    @rooms = params[:inactive_rooms].present? ? Room.classrooms_inactive : Room.classrooms
    if params[:direction].present?
      @sorted = true
      @rooms = @rooms.includes(:notes, :room_contact, {building: [:notes, {building_image_attachment: {blob: :variant_records}}]},
        room_image_attachment: {blob: :variant_records})
        .reorder(instructional_seating_count: params[:direction].to_sym)
    else
      @rooms = @rooms.includes(:notes, :room_contact, {building: [:notes, {building_image_attachment: {blob: :variant_records}}]},
        room_image_attachment: {blob: :variant_records}).reorder(:building_name)
      floors = sort_floors(@rooms.pluck(:floor).uniq)
      @rooms = @rooms.order_as_specified(floor: floors).order(room_number: :asc)
    end
    @rooms = @rooms.with_building_name(params[:building_name]) if params[:building_name].present?
    if params[:school_or_college_name].present?
      @rooms = @rooms.with_school_or_college_name(params[:school_or_college_name])
    end
    @rooms = @rooms.with_all_characteristics(params[:room_characteristics]) if params[:room_characteristics].present?
    if params[:min_capacity].present?
      @rooms = @rooms.where("instructional_seating_count >= ?",
        params[:min_capacity].to_i)
    end
    if params[:max_capacity].present?
      @rooms = @rooms.where("instructional_seating_count <= ?",
        params[:max_capacity].to_i)
    end
    if params[:classroom_name].present?
      term = params[:classroom_name].strip
      if term.present?
        compact = term.upcase.gsub(/\s+/, "")
        like_pattern = "%#{Room.sanitize_sql_like(compact)}%"
        @rooms = @rooms.where(
          "tsv @@ websearch_to_tsquery('pg_catalog.simple', ?) OR UPPER(facility_code_heprod) LIKE ? OR UPPER(COALESCE(nickname, '')) LIKE ?",
          term,
          like_pattern,
          like_pattern
        )
      end
    end

    authorize @rooms

    @rooms = RoomDecorator.decorate_collection(@rooms)

    @pagy, @rooms = pagy(@rooms)
    @rooms_search_count = @pagy.count

    if turbo_frame_request?
      render partial: "listing"
    else
      render "index"
    end
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    @page_title = "Room #{@room.room_number} - #{@room.building.name}"
    visible_ok = (@room.visible && @room.building.visible) || session[:user_admin]
    unless visible_ok
      redirect_to rooms_path, notice: "Room is inactive" and return
    end
    @room_chars = @room.room_characteristics.select { |c| c }
    @room_chars_short = @room.characteristics
    @building = @room.building
    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /rooms/1/edit
  def edit
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        begin
          @room.generate_thumbnails if @room.room_image.attached?
          format.html { redirect_to @room, notice: "Room was successfully updated." }
          format.json { render :show, status: :ok, location: @room }
        rescue ActiveStorage::FileNotFoundError => e
          Rails.logger.error "Failed to process image: #{e.message}"
          format.html { redirect_to @room, notice: "Room was updated but image processing failed." }
          format.json { render json: {error: "Image processing failed"}, status: :unprocessable_entity }
        end
      else
        flash.now[:alert] = @room.errors.full_messages.to_sentence
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity, formats: [:html] }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  def floor_plan
    @floor_list = @room.building.floors
    @building = @room.building
    @rooms_list = Room.where(building_bldrecnbr: @room.building, floor: @room.floor,
      rmtyp_description: "Classroom").where.not(facility_code_heprod: nil).order(:room_number)
  end

  def toggle_visible
    was_visible = @room.visible
    @room.update!(visible: !was_visible)
    notice = @room.visible ? "Room is now active." : "Room is now inactive."
    redirect_back fallback_location: room_path(@room), notice: notice
  end

  private

  def set_room_for_toggle_visible
    @room = Room.find(params[:id])
    authorize @room, :toggle_visible?
  end

  def set_room
    # fresh_when @room
    # @room = Room.includes(:building, :room_characteristics, :room_panorama_attachment, :room_contact).find(params[:id])
    @room = Room.includes(
      :notes,
      {building: :notes},
      {room_panorama_attachment: :blob},
      {room_image_attachment: :blob},
      {room_layout_attachment: :blob},
      {gallery_image1_attachment: :blob},
      {gallery_image2_attachment: :blob},
      {gallery_image3_attachment: :blob},
      {gallery_image4_attachment: :blob},
      {gallery_image5_attachment: :blob}
    ).find(params[:id])
    fresh_when last_modified: @room.updated_at
    @room = @room.decorate
    authorize @room
  end

  # Only allow a list of trusted parameters through.
  def room_params
    params.require(:room).permit(:rmrecnbr, :floor, :room_number, :rmtyp_description,
      :dept_id, :dept_grp, :dept_description, :square_feet,
      :instructional_seating_count, :visible, :building_bldrecnbr,
      :room_characteristics, :min_capacity, :max_capacity,
      :school_or_college_name, :inactive_buildings, :inactive_rooms,
      :room_image, :room_panorama,
      :room_layout, :gallery_image1, :gallery_image2,
      :gallery_image3, :gallery_image4, :gallery_image5)
  end

  def filtering_params
    params.slice(:bluray, :chalkboard, :doccam, :interactive_screen, :instructor_computer, :lecture_capture,
      :projector_16mm, :projector_35mm, :projector_digital_cinema, :projector_digial, :projector_slide, :team_board, :team_tables, :team_technology, :vcr, :video_conf, :whiteboard)
  end

  def set_filters_list
    filters = {}
    if params.present?
      capacity = ""
      params.each do |k, v|
        if k == "inactive_rooms"
          filters["Filters"] = k.titleize
          break
        end
        if k == "inactive_buildings"
          filters = {}
          break
        end
        next unless !%w[controller action direction format page items].include?(k) && !v.empty?

        case k
        when "school_or_college_name"
          filters["School"] = v
        when "building_name"
          filters["Building"] = "*" + v + "*"
        when "classroom_name"
          filters["Classroom"] = "*" + v + "*"
        when "min_capacity"
          capacity = v
        when "max_capacity"
          unless v == "600" && capacity == "0"
            capacity = capacity + "-" + v
            filters["Capacity"] = capacity
          end
        when "room_characteristics"
          names = []
          v.each do |item|
            names << RoomCharacteristic.find_by(chrstc_descrshort: item).chrstc_descr.sub(/.*?:/, "").lstrip
          end
          n = names.join(", ")
          filters["Filters"] = n
        else
          filters[k] = v
        end
      end

      if capacity.present? && !filters.key?("Capacity")
        if params[:max_capacity].present? && !(params[:max_capacity].to_s == "600" && capacity.to_s == "0")
          filters["Capacity"] = "#{capacity}-#{params[:max_capacity]}"
        elsif params[:max_capacity].blank?
          filters["Capacity"] = "#{capacity}+"
        end
      end
    end
    @filters_list = filters.map do |key, val|
      key + ": " + val
    end.join(", ")
  end

  def sort_floors(floors)
    floors.sort_by do |s|
      if s =~ /^\d+$/
        [2, ::Regexp.last_match(0).to_i]
      else
        [1, s]
      end
    end
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
  end
end
