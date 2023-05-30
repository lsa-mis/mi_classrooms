class BuildingsController < ApplicationController
  before_action :set_redirection_url
  before_action :authenticate_user!
  before_action :set_building, only: [:show, :edit, :update]

  # GET /buildings
  # GET /buildings.json
  def index
    @schools = Room.classrooms.pluck(:dept_group_description).uniq.compact.sort

    buildings_ids = Room.classrooms.pluck(:building_bldrecnbr).uniq
    if params[:inactive_buildings].present?
      @buildings = Building.where(bldrecnbr: buildings_ids, visible: false).order(:name)
    else
      @buildings = Building.where(bldrecnbr: buildings_ids).order(:name)
    end
    if params[:building_name].present?
      session[:building_name] = params[:building_name]
      @buildings = @buildings.with_name(params[:building_name])
    end
      authorize @buildings
      @pagy, @buildings = pagy(@buildings)

    if turbo_frame_request?
      render partial: "listing"
    else
      render "index"
    end
  end

  # GET /buildings/1
  # GET /buildings/1.json
  def show
    @class_floor_names = @building.rooms.where(rmtyp_description: "Classroom").pluck(:floor).uniq.compact.sort
  end

  # GET /buildings/1/edit
  def edit
    @floors = @building.rooms.where(rmtyp_description: "Classroom").pluck(:floor).uniq.compact.sort
  end

  # PATCH/PUT /buildings/1
  # PATCH/PUT /buildings/1.json
  def update
    respond_to do |format|
      if @building.update(building_params)
        format.html { redirect_to @building, notice: 'Building was successfully updated.' }
        format.json { render :show, status: :ok, location: @building }
      else
        format.html { redirect_to @building, alert:  @building.errors.full_messages }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_redirection_url
      $baseURL = request.fullpath
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = Building.find(params[:id])
      authorize @building
    end

    # Only allow a list of trusted parameters through.
    def building_params
      params.require(:building).permit(:bldrecnbr, :latitude, :longitude, :name, :nick_name, :abbreviation, :address, :city, :state, :zip, :country, :building_name, :visible, :inactive_buildings, :building_image)
    end

end
