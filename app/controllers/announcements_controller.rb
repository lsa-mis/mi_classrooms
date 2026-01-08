class AnnouncementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_announcement, only: [:show, :edit, :update, :destroy]

  def index
    @page_title = "Announcements"
    @announcements = Announcement.all.with_rich_text_content.order(:id)
    authorize @announcements
  end

  def show
  end

  def new
    @announcement = Announcement.new(location: params[:location])
    authorize @announcement
  end

  def create
    @announcement = Announcement.new(announcement_params)
    authorize @announcement

    if @announcement.save
      redirect_to announcements_path, notice: 'Announcement was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @announcement.update(announcement_params)
      redirect_to announcements_path, notice: 'Announcement was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @announcement.destroy
    redirect_to announcements_path, notice: 'Announcement was successfully deleted.'
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
