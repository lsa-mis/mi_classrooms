require 'rails_helper'

RSpec.describe 'Room Characteristics', type: :system, js: true do
  let(:user) { create(:user) }
  let!(:building) { create(:building, name: 'Tech Building') }
  
  let!(:room_with_projector) { create(:room, :classroom, building: building, facility_code_heprod: 'TECH101') }
  let!(:room_with_wifi) { create(:room, :classroom, building: building, facility_code_heprod: 'TECH201') }
  let!(:room_with_both) { create(:room, :classroom, building: building, facility_code_heprod: 'TECH301') }

  before do
    # Create room characteristics
    create(:room_characteristic, :projector, room: room_with_projector)
    create(:room_characteristic, :wifi, room: room_with_wifi)
    create(:room_characteristic, :projector, room: room_with_both, chrstc: 1)
    create(:room_characteristic, :wifi, room: room_with_both, chrstc: 2)

    # Populate the denormalized characteristics array used by filters
    room_with_projector.update!(characteristics: ['ProjDigit'])
    room_with_wifi.update!(characteristics: ['WiFi'])
    room_with_both.update!(characteristics: ['ProjDigit', 'WiFi'])

    # Mock authentication
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
  end

  scenario 'User filters rooms by single characteristic' do
    visit rooms_path

    # Assuming there's a characteristics filter
    # The checkbox id is underscored chrstc_descrshort per view
    check 'proj_digit'

    expect(page).to have_content('TECH101')
    expect(page).to have_content('TECH301')
    expect(page).not_to have_content('TECH201')
  end

  scenario 'User filters rooms by multiple characteristics' do
    visit rooms_path

    check 'proj_digit'
    check 'wi_fi'

    # Should only show room that has BOTH characteristics
    expect(page).to have_content('TECH301')
    expect(page).not_to have_content('TECH101')
    expect(page).not_to have_content('TECH201')
  end

  scenario 'User views room characteristics on room detail page' do
    visit room_path(room_with_both)

    expect(page).to have_content('Room characteristics'.upcase).or have_content('Room characteristics')
  end

  scenario 'User sees characteristic icons or indicators' do
    visit rooms_path

    # Rooms with characteristics should show some visual indicator
    # This would depend on the actual UI implementation
    expect(page).to have_content('Tech Building')
    expect(page).to have_content('Projector')
    expect(page).to have_content('WiFi')
  end

  scenario 'User accesses room filters glossary' do
    visit room_filters_glossary_path

    expect(page).to have_content('Room Filters Glossary')
  end
end