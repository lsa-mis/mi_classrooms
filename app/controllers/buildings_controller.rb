class BuildingsController < ApplicationController
  before_action :set_redirection_url
  before_action :authenticate_user!
  before_action :set_building, only: [:show, :edit, :update, :destroy]

  # GET /buildings
  # GET /buildings.json
  def index
    # @searchable_buildings =  Building.with_classrooms.ann_arbor_campus.uniq.pluck(:name, :abbreviation).collect{ |building| [building[0].titleize, building[1] ] }.sort
    @schools = Room.classrooms.pluck(:dept_group_description).uniq.sort

    buildings_ids = Room.classrooms.pluck(:building_bldrecnbr).uniq
    if params[:not_visible_buildings].present?
      @buildings = Building.where(bldrecnbr: buildings_ids, visible: false).order(:name)
    else
      @buildings = Building.where(bldrecnbr: buildings_ids, visible: true).order(:name)
    end
    if params[:query].present?
      session[:query] = params[:query]
      @buildings = @buildings.with_name(params[:query])
    end
      authorize @buildings
      @pagy, @buildings = pagy(@buildings)
    # else
    #   @buildings = Building.all
    #   authorize @buildings
    #   @pagy, @buildings = pagy(@buildings)
    # end

    # unless params[:query].nil?
    #   render turbo_stream: turbo_stream.replace(
    #   :buildingListing,
    #   partial: "buildings/listing"
    # )
    # end

  end

  # GET /buildings/1
  # GET /buildings/1.json
  def show
    @class_floor_names = @building.rooms.where(rmtyp_description: "Classroom").pluck(:floor).uniq.sort
  end


  # GET /buildings/1/edit
  def edit
    @floors = @building.rooms.where(rmtyp_description: "Classroom").pluck(:floor).uniq.sort
  end

  # PATCH/PUT /buildings/1
  # PATCH/PUT /buildings/1.json
  def update
    respond_to do |format|
      if @building.update(building_params)
        format.html { redirect_to @building, notice: 'Building was successfully updated.' }
        format.json { render :show, status: :ok, location: @building }
      else
        format.html { render :edit }
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
      params.require(:building).permit(:bldrecnbr, :latitude, :longitude, :name, :nick_name, :abbreviation, :address, :city, :state, :zip, :country, :query, :visible, :not_visible_buildings, :building_image)
    end

end
