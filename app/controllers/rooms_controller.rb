class RoomsController < ApplicationController
include ActionView::RecordIdentifier
  devise_group :logged_in, contains: [:user]
  before_action :authenticate_logged_in!  
  skip_after_action :verify_policy_scoped, only: :index
  before_action :set_room, only: [:show, :edit, :update, :destroy, :toggle_visibile]
  before_action :set_filters_list, only: [:index]
  before_action :set_characteristics_array, only: [:index, :show]

  include ApplicationHelper 

  def index
    @sorted = false
    buildings_ids = Room.classrooms.pluck(:building_bldrecnbr).uniq
    @buildings = Building.where(bldrecnbr: buildings_ids).order(:name)
    @rooms_page_announcement = Announcement.find_by(location: "find_a_room_page")
    @all_rooms_number = Room.classrooms.count
    @schools = Room.classrooms.pluck(:dept_group_description).uniq.sort
    if params[:direction].present?
      @sorted = true
      @rooms = Room.classrooms.includes([:building, :room_contact]).reorder(:instructional_seating_count => params[:direction].to_sym)
    else
      @rooms = Room.classrooms.includes([:building, :room_contact]).reorder(:building_name)
      floors = sort_floors(@rooms.pluck(:floor).uniq)
      @rooms = @rooms.order_as_specified(floor: floors).order(:room_number => :asc)
    end
    @rooms = @rooms.with_building_name(params[:query]) if params[:query].present?
    @rooms = @rooms.with_school_or_college_name(params[:school_or_college_name]) if params[:school_or_college_name].present?
    @rooms = @rooms.with_all_characteristics(params[:room_characteristics]) if params[:room_characteristics].present?
    @rooms = @rooms.where('instructional_seating_count >= ?', params[:min_capacity].to_i) if params[:max_capacity].present?
    @rooms = @rooms.where('instructional_seating_count <= ?', params[:max_capacity].to_i) if params[:max_capacity].present?
    @rooms = @rooms.where('facility_code_heprod LIKE ?', "%#{params[:classroom_name].upcase}%") if params[:classroom_name].present?

    authorize @rooms

    @rooms = RoomDecorator.decorate_collection(@rooms)
    
    @pagy, @rooms = pagy(@rooms)
    @rooms_search_count = @pagy.count

  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    @room_chars = @room.room_characteristics.select { |c| c}
    @room_chars_short = @room.characteristics
    authorize @room
    respond_to do |format|
      format.html
      format.json { render json: @room, serializer: RoomSerializer }
    end
  end

  # GET /rooms/1/edit
  def edit
    authorize @room
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    authorize @room
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_visibile
    authorize @room
    @room.toggle! :visible
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully updated.' }
      format.turbo_stream { render turbo_stream: turbo_stream.update(dom_id(@room)), notice: 'Room was successfully updated.' }
    end
  end

  private

    def set_room
      fresh_when @room
      @room = Room.includes(:building, :room_characteristics, :room_panorama_attachment, :room_contact).find(params[:id])
      @room = @room.decorate
    end
    
    # Only allow a list of trusted parameters through.
    def room_params
      params.require(:room).permit(:rmrecnbr, :floor, :room_number, :rmtyp_description, :dept_id, :dept_grp, :dept_description, :square_feet, :instructional_seating_count, :visible, :building_bldrecnbr, :room_characteristics, :min_capacity, :max_capacity, :school_or_college_name, :room_image, :room_panorama, :room_layout)
    end

    def filtering_params
      params.slice(:bluray, :chalkboard, :doccam, :interactive_screen, :instructor_computer, :lecture_capture, :projector_16mm, :projector_35mm, :projector_digital_cinema, :projector_digial, :projector_slide, :team_board, :team_tables, :team_technology, :vcr, :video_conf, :whiteboard)
    end

    def set_filters_list
      filters = {}
      if params.present?
        capacity = ""
        params.each do |k, v|
          unless k == 'controller' || k == 'action' || k == 'direction' || k == 'format' || k == 'page' || k == 'items'
            unless v.empty?
              case k
              when "school_or_college_name"
                filters['School'] = v
              when "query"
                filters['Building'] = "*" + v + "*"
              when "classroom_name"
                filters['Classroom'] = "*" + v + "*"
              when "min_capacity"
                capacity = v
              when 'max_capacity'
                unless v == "600" && capacity == "0"
                  capacity = capacity + "-" + v
                  filters['Capacity'] = capacity
                end
              when "room_characteristics"
                names = []
                v.each do |item|
                  names << RoomCharacteristic.find_by(chrstc_descrshort: item).chrstc_descr.sub(/.*?:/, '').lstrip
                end
                n = names.join(', ')
                filters['Filters'] = n
              else
                filters[k] = v
              end
            end
          end
        end
      end
      @filters_list = filters.map do |key, val|
        key + ': ' + val
      end.join(', ')
    end

    def sort_floors(floors)
      sorted = floors.sort_by do |s|
        if s =~ /^\d+$/
          [2, $&.to_i]
        else
          [1, s]
        end
      end
      return sorted
    end

end
