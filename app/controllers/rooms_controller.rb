class RoomsController < ApplicationController
include ActionView::RecordIdentifier
  before_action :set_room, only: [:show, :edit, :update, :destroy, :toggle_visibile]

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.classrooms.includes([:building, :room_contact])

    @rooms = @rooms.classrooms.with_building_name(params[:query]) if params[:query].present?

    @rooms = @rooms.classrooms.with_all_characteristics(params[:room_characteristics]) if params[:room_characteristics].present?

    @rooms = RoomDecorator.decorate_collection(@rooms)
    @pagy, @rooms = pagy(@rooms)

  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    respond_to do |format|
      # format.js
      format.html
      format.json { render json: @room, serializer: RoomSerializer }
    end
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
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

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@room))}
    end
  end

  def toggle_visibile
    @room.toggle! :visible
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully updated.' }
      format.turbo_stream { render turbo_stream: turbo_stream.update(dom_id(@room)), notice: 'Room was successfully updated.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def room_params
      params.require(:room).permit(:rmrecnbr, :floor, :room_number, :rmtyp_description, :dept_id, :dept_grp, :dept_description, :square_feet, :instructional_seating_count, :visible, :building_bldrecnbr, :room_characteristics)
    end

    def filtering_params
      params.slice(:bluray, :chalkboard, :doccam, :interactive_screen, :instructor_computer, :lecture_capture, :projector_16mm, :projector_35mm, :projector_digital_cinema, :projector_digial, :projector_slide, :team_board, :team_tables, :team_technology, :vcr, :video_conf, :whiteboard).values
    end

    def filtering_params
      params.slice(:filter_params)
    end
end
