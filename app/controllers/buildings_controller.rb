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
    authorize @building
  end

  # GET /buildings/new
  def new
    @building = Building.new
  end

  # GET /buildings/1/edit
  def edit
    authorize @building
  end

  # POST /buildings
  # POST /buildings.json
  def create
    @building = Building.new(building_params)

    respond_to do |format|
      if @building.save
        format.html { redirect_to @building, notice: 'Building was successfully created.' }
        format.json { render :show, status: :created, location: @building }
      else
        format.html { render :new }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
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

  # DELETE /buildings/1
  # DELETE /buildings/1.json
  def destroy
    @building.destroy
    respond_to do |format|
      format.html { redirect_to buildings_url, notice: 'Building was successfully destroyed.' }
      format.json { head :no_content }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@building))}
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
