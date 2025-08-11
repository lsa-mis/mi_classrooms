require 'rails_helper'

RSpec.describe 'User Authentication', type: :system do
  let(:user) { create(:user) }

  scenario 'Unauthenticated user is redirected to sign in' do
    # Override global system-spec auth stubs for this example
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_call_original
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_call_original

    visit rooms_path

    # Devise sessions page redirects to root in this app
    expect(page).to have_current_path(new_user_session_path, url: false).or have_current_path(root_path, url: false)
  end

  scenario 'Authenticated user can access rooms' do
    # Mock successful authentication
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)

    # Bypass Pundit in system spec context
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:verify_authorized).and_return(true)

    visit rooms_path

    expect(page).to have_content('Classrooms')
  end

  scenario 'User without proper authorization sees access denied' do
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)

    visit rooms_path

    # Check if page shows not authorized OR is redirected to about page
    expect(page.has_content?('not authorized') || current_path == about_path).to be_truthy
  end

  scenario 'User can access about page without authentication' do
    visit about_path

    expect(page).to have_content('About The MClassrooms application.')
  end
end