class Buildings::FloorsController < ApplicationController

  before_action :set_building

  def show 
    @floors = @building.floors
    @floor = @building.floors.find(params[:id])
    @building_rooms_list = Room.where(building_bldrecnbr: @building, rmtyp_description: "Classroom")
    @floor_rooms_list = Room.where(building_bldrecnbr: @building, rmtyp_description: "Classroom", floor: @floor.floor).order(:room_number)
    authorize @floors
  end

  def new

  end

  def create
    @floor = Floor.new(floor_params)
    @floor.building_bldrecnbr = @building.bldrecnbr
    authorize @floor

    respond_to do |format|
      if @floor.save 
        format.turbo_stream { redirect_to @building, 
                              notice: "The floor plan was added" 
                            }
      else
        error = @floor.errors.full_messages
        format.turbo_stream { redirect_to @building, 
          alert: error
        }
      end
    end
  end

  def edit
    @floors = @buildings.floors
    authorize @floors

  end

  def update
    @floor = Floor.find(params[:id])
    authorize @floor
    respond_to do |format|
      if @floor.update(floor_params)
        format.turbo_stream { redirect_to @building, 
        notice: "The floor plan was updated" 
      }
      else
        error = @floor.errors.full_messages
        format.turbo_stream { redirect_to @building, 
        alert: error
        }
      end
    end

  end

  def destroy
    @floor = Floor.find(params[:id])
    authorize @floor
    @floor.destroy
    redirect_back(fallback_location: request.referer, 
                  notice: "Floor map was deleted")
  end

  private
  
    def floor_params
      params.require(:floor).permit(:floor, :floor_plan)
    end

    def set_building
      @building = Building.find_by(bldrecnbr: params[:building_id])
    end

end
