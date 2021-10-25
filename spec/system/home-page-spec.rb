require 'rails_helper'

RSpec.describe 'Home Page', type: :system do

  describe 'home page' do
    it 'shows the right content' do
      visit root_path
      expect(page).to have_content('Makes finding the right room easy!')
      sleep(inspection_time=3)
    end
  end
end