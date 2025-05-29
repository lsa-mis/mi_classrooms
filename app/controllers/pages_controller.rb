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
    characteristics = RoomCharacteristic.all.pluck(:chrstc_descrshort, :chrstc_desc254).uniq
    characteristics.delete_if {|x| x.include?(nil)}
    characteristics.sort
    @filters_hash = {}
    characteristics.each do |key, value|
      @filters_hash[key] = value
    end
    @category_letters = []
    @all_characteristics_array.each do |c|
      @category_letters << c[0][0]
    end
    @category_letters = @category_letters.uniq.sort
  end

end
