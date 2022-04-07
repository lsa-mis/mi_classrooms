class Buildings::NotesController < ApplicationController
  include Noteable

  before_action :set_noteable

  private

    def set_noteable
      @noteable = Building.find_by(bldrecnbr: params[:building_id])
    end
end
