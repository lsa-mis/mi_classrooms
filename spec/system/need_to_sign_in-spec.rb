require 'rails_helper'

RSpec.describe 'Need to sign in', type: :system do

  before :each do
    load "#{Rails.root}/spec/support/test_seeds.rb" 
  end

  describe 'rooms page' do
    it 'shows the message to sign in' do
      visit rooms_path
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

  describe 'buildings page' do
    it 'shows the message to sign in' do
      visit buildings_path
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

  describe 'room show page' do
    it 'shows the message to sign in' do
      visit room_path(1000010)
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

  describe 'room edit page' do
    it 'shows the message to sign in' do
      visit edit_room_path(1000010)
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

  describe 'building show page' do
    it 'shows the message to sign in' do
      visit building_path(1000001)
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

  describe 'building edit page' do
    it 'shows the message to sign in' do
      visit edit_building_path(1000001)
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

  describe 'announcements page' do
    it 'shows the message to sign in' do
      visit announcements_path
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

  describe 'announcement edit page' do
    it 'shows the message to sign in' do
      visit announcement_path(1)
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

  describe 'room_filters_glossary page' do
    it 'shows the message to sign in' do
      visit room_filters_glossary_path
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

  describe 'room_filters_glossary page' do
    it 'message to sign in should dessapear after 3 seconds' do
      visit room_filters_glossary_path
      expect(page).to have_content('You need to sign in')
      sleep(inspection_time=3)
      expect(page).not_to have_content('You need to sign in')
      sleep(inspection_time=1)
    end
  end

end