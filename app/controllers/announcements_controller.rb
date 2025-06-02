class AnnouncementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_announcement, only: [:show, :edit, :update, :cancel]

  def index
    @page_title = "Announcements"
    @announcements = Announcement.all.with_rich_text_content.order(:id)
    authorize @announcements
  end

  def show
  end

  def edit
    session[:return_to] = request.referer
  end

  def update
    respond_to do |format|
      if @announcement.update(announcement_params)
        format.turbo_stream { redirect_to session.delete(:return_to),
        notice: 'Text was successfully updated.'
      }
    else
      format.turbo_stream
      end
    end
  end

  def cancel
    redirect_to session.delete(:return_to)
  end

  private

    def set_announcement
      @announcement = Announcement.find(params[:id])
      authorize @announcement

    end

    def announcement_params
      params.require(:announcement).permit(:location, :content)
    end

end
