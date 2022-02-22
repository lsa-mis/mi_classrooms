require 'rails_helper'

RSpec.describe 'Home Page', type: :system do

  describe 'about page' do
    it 'shows the right content' do
      visit about_path
      expect(page).to have_content('About The MClassrooms application')
      sleep(inspection_time=3)
    end
  end
end