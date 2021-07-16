class PagesController < ApplicationController
  def index
  end

  def about
    flash[:alert] = "I like to boogie."
    flash[:error] = "There has been an error."
    flash[:success] = "I like to get down."

  end

  def contact
  end

  def privacy
  end
end
