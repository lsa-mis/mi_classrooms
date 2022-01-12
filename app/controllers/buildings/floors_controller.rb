class Buildings::FloorsController < ApplicationController

  before_action :set_building

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

  private
  
    def floor_params
      params.require(:floor).permit(:floor, :floor_plan)
    end

    def set_building
      @building = Building.find_by(bldrecnbr: params[:building_id])
    end

end
