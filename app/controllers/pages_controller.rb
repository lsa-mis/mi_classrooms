class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:room_filters_glossary]
  before_action :set_characteristics_array, only: [:room_filters_glossary]
  after_action :verify_authorized, except: [:index, :about]

  def about
    @about_page_announcement = Announcement.find_by(location: "about_page")
  end

  def index
    @page_title = "Home"
    @index_page_announcement = Announcement.find_by(location: "home_page")
    if current_user
      redirect_to rooms_path unless current_user.admin
    end
  end

  def room_filters_glossary
    authorize :page
    @page_title = "Room Filters Glossary"
    @glossary_categories = @all_characteristics_array
    @category_letters = @glossary_categories.keys.map { |category| category[0] }.uniq.sort
  end
end
