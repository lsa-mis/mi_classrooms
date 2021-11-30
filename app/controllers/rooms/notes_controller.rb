class Rooms::NotesController < ApplicationController
  include Noteable

  before_action :set_noteable

  private

    def set_noteable
      @noteable = Room.find_by(rmrecnbr: params[:room_id])
      # @noteable = Room.find(params[:room_id])
    end
end