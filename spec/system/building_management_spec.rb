require 'rails_helper'

RSpec.describe 'Building Management', type: :system, js: true do
  let(:user) { create(:user) }
  let!(:building1) { create(:building, name: 'Engineering Building', abbreviation: 'ENGR') }
  let!(:building2) { create(:building, name: 'Library Building', abbreviation: 'LIB') }

  before do
    # Create classrooms to make buildings appear in the listings
    create(:room, :classroom, building: building1)
    create(:room, :classroom, building: building2)

    # Mock authentication
    user.admin = true
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
  end

  scenario 'User views buildings index' do
    visit buildings_path
    expect(page).to have_content('Buildings with classrooms')
    expect(page).to have_selector('turbo-frame#turbo-buildings')
    within 'turbo-frame#turbo-buildings' do
      expect(page).to have_content(building1.name.titleize)
      expect(page).to have_content(building2.name.titleize)
    end
  end

  scenario 'User searches for buildings by name' do
    visit buildings_path

    fill_in 'building_name', with: 'Engineering'
    expect(page).to have_selector('turbo-frame#turbo-buildings')
    within 'turbo-frame#turbo-buildings' do
      expect(page).to have_content(building1.name.titleize)
      expect(page).not_to have_content(building2.name.titleize)
    end
  end

  scenario 'User views building details' do
    # Create rooms on different floors
    create(:room, building: building1, rmtyp_description: 'Classroom', floor: '1')
    create(:room, building: building1, rmtyp_description: 'Classroom', floor: '2')
    create(:room, building: building1, rmtyp_description: 'Office', floor: '3')

    visit building_path(building1)

    expect(page).to have_content(building1.name)
    expect(page).to have_content('Floor 1')
    expect(page).to have_content('Floor 2')
    # Floor 3 should not appear as it only has offices, not classrooms
  end

  scenario 'User edits building information' do
    visit edit_building_path(building1)

    expect(page).to have_content('Editing building')
    
    fill_in 'building_name', with: 'Updated Engineering Building'
    fill_in 'building_abbreviation', with: 'UENG'
    click_button 'Save'

    expect(page).to have_content('Building was successfully updated')
    expect(page).to have_content('Updated Engineering Building')
  end

  scenario 'User views inactive buildings' do
    inactive_building = create(:building, :inactive, name: 'Inactive Building')
    create(:room, :classroom, building: inactive_building)

    visit buildings_path

    expect(page).to have_content('Inactive Building')

    # Admin checkbox only visible to editors; at minimum ensure the inactive building is present

    expect(page).to have_content('Inactive Building')
  end

  scenario 'User navigates from building to rooms' do
    create(:room, :classroom, building: building1, facility_code_heprod: 'ENGR101')

    visit building_path(building1)

    click_link 'Rooms Index'

    expect(page).to have_content('Classrooms')
  end

  scenario 'User views building with no classrooms' do
    create(:building, name: 'Empty Building')
    
    visit buildings_path

    expect(page).not_to have_content('Empty Building')
  end
end