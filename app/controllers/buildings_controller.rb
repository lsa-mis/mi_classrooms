class BuildingsController < ApplicationController

  before_action :set_building, only: [:show, :edit, :update, :destroy]
  skip_after_action :verify_policy_scoped, only: :index

  # GET /buildings
  # GET /buildings.json
  def index
    @searchable_buildings =  Building.with_classrooms.ann_arbor_campus.uniq.pluck(:nick_name, :abbreviation).collect{ |building| [building[0].titleize, building[1] ] }.sort
    if params[:query].present?
      session[:query] = params[:query]
      @buildings = Building.with_name(params[:query])
      authorize @buildings
      @pagy, @buildings = pagy(@buildings)
    else
      @buildings = Building.all
      authorize @buildings
      @pagy, @buildings = pagy(@buildings)
    end

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
    @bld_floor_names = @building.floors.pluck(:floor)
    @bld_floors = @building.floors

    authorize @building
  end


  # GET /buildings/1/edit
  def edit
    @floors = @building.rooms.where(rmtyp_description: "Classroom").pluck(:floor).uniq.sort
    authorize @building
  end

  # PATCH/PUT /buildings/1
  # PATCH/PUT /buildings/1.json
  def update
    authorize @building
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
    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = Building.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def building_params
      params.require(:building).permit(:bldrecnbr, :latitude, :longitude, :name, :nick_name, :abbreviation, :address, :city, :state, :zip, :country, :query, :building_image)
    end

end
