class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note

  def update
    if @note.update(note_params) && @note.update(user: current_user)
      redirect_to @note
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.turbo_stream {}
      format.html { redirect_to @note.noteable }
    end
  end

  private

  def set_note
    @note = Note.find(params[:id])
    authorize @note
  end

  def note_params
    params.require(:note).permit(:body, :alert)
  end
end