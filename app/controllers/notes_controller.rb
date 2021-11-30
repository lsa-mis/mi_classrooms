class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note

  def show
    authorize @note
  end

  def edit
    authorize @note
  end

  def update
    authorize @note
    if @note.update(note_params)
      redirect_to @note
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @note
    @note.destroy
    respond_to do |format|
      format.turbo_stream {}
      format.html { redirect_to @note.noteable }
    end
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:body)
  end
end