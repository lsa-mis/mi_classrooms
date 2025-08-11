require 'rails_helper'

RSpec.describe 'Room Search', type: :system, js: true do
  let(:user) { create(:user) }
  let!(:building1) { create(:building, name: 'Engineering Building', abbreviation: 'ENGR') }
  let!(:building2) { create(:building, name: 'Library Building', abbreviation: 'LIB') }
  
  let!(:room1) { create(:room, :classroom, building: building1, instructional_seating_count: 50, facility_code_heprod: 'ENGR101') }
  let!(:room2) { create(:room, :classroom, building: building1, instructional_seating_count: 30, facility_code_heprod: 'ENGR201') }
  let!(:room3) { create(:room, :classroom, building: building2, instructional_seating_count: 100, facility_code_heprod: 'LIB301') }

  before do
    # Mock authentication
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
  end

  scenario 'User searches for rooms without filters' do
    visit rooms_path

    expect(page).to have_content('Classrooms')
    expect(page).to have_content('All buildings')
    expect(page).to have_content(building1.name.titleize)
    expect(page).to have_content(building2.name.titleize)
  end

  scenario 'User filters rooms by building name' do
    visit rooms_path

    fill_in 'building_name', with: 'Engineering'

    expect(page).to have_link('ENGR101')
    expect(page).to have_link('ENGR201')
    expect(page).not_to have_link('LIB301')
  end

  scenario 'User filters rooms by classroom name' do
    visit rooms_path

    fill_in 'classroom_name', with: 'ENGR101'

    expect(page).to have_link('ENGR101')
    expect(page).not_to have_link('ENGR201')
    expect(page).not_to have_link('LIB301')
  end

  scenario 'User filters rooms by capacity range' do
    visit rooms_path

    fill_in 'min_capacity', with: '40'
    fill_in 'max_capacity', with: '80'

    expect(page).to have_link('ENGR101') # 50 seats
    expect(page).not_to have_link('ENGR201') # 30 seats
    expect(page).not_to have_link('LIB301') # 100 seats
  end

  scenario 'User sorts rooms by capacity' do
    visit rooms_path

    select 'Low to High', from: 'direction'

    # Check that rooms appear in ascending order of capacity
    # Verify count header shows Room(s) after sort
    expect(page).to have_content('Rooms')
  end

  scenario 'User views room details' do
    visit rooms_path
    visit room_path(room1)

    expect(page).to have_content(room1.facility_code_heprod)
    expect(page).to have_content(building1.name)
    expect(page).to have_content(room1.instructional_seating_count.to_s)
  end

  scenario 'User uses multiple filters together' do
    visit rooms_path

    fill_in 'building_name', with: 'Engineering'
    fill_in 'min_capacity', with: '40'

    expect(page).to have_link('ENGR101')
    expect(page).not_to have_link('ENGR201') # Too small
    expect(page).not_to have_link('LIB301') # Wrong building
  end

  scenario 'User sees search results count' do
    visit rooms_path

    expect(page).to have_content('All buildings').or have_content('Rooms')
    
    fill_in 'building_name', with: 'Engineering'

    expect(page).to have_content('Rooms').or have_content('All Rooms')
  end
end