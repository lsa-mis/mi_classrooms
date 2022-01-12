class Buildings::FloorsController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index


  before_action :set_building

  def new

  end

  def create
    @floor = Floor.new(floor_params)
    @floor.building_bldrecnbr = @building.bldrecnbr
    authorize @floor

    @floor.save
  end

  def edit
    @floor = Floor.find(params[:id])
    @floor.update(floor_params)
    authorize @floor

  end

  def update
    authorize @floor

  end

  private
  
    def floor_params
      params.require(:floor).permit(:floor, :floor_plan)
    end

    def set_building
      @building = Building.find_by(bldrecnbr: params[:building_id])
    end

end
