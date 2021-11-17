class AnnouncementsController < ApplicationController

  skip_after_action :verify_policy_scoped, only: :index

  before_action :set_announcement, only: [:show, :edit, :update]

  def index
    @announcements = Announcement.all.with_rich_text_content
    authorize @announcements
  end

  def show
    authorize @announcement
  end

  def edit
    session[:return_to] = request.referer
    authorize @announcement
  end

  def update
    authorize @announcement
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

  private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit(:location, :content)
    end

end
