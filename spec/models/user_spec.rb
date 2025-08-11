require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:omni_auth_services).dependent(:destroy) }
    it { should have_many(:notes) }
  end

  describe 'validations' do
    # Test actual model behavior rather than specific validations
    it 'creates user with password' do
      user = build(:user)
      expect(user.password).to be_present
      expect(user).to be_valid
    end

    it 'validates email uniqueness through database constraint' do
      create(:user, email: 'test@example.com')
      duplicate_user = build(:user, email: 'test@example.com')
      expect { duplicate_user.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'devise modules' do
    it 'includes database_authenticatable module' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes rememberable module' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes omniauthable module' do
      expect(User.devise_modules).to include(:omniauthable)
    end
  end

  describe 'attributes' do
    let(:user) { build(:user) }

    it 'has membership accessor' do
      user.membership = ['admin']
      expect(user.membership).to eq(['admin'])
    end

    it 'has admin accessor' do
      user.admin = true
      expect(user.admin).to be true
    end
  end

  describe '.from_omniauth' do
    let(:auth) do
      double('auth',
        info: double(
          email: 'test@example.com',
          uid: '12345',
          name: 'Test User',
          principal_name: 'test@example.com',
          person_affiliation: 'student'
        )
      )
    end

    it 'calls find_or_create_user' do
      expect(User).to receive(:find_or_create_user).with(auth)
      User.from_omniauth(auth)
    end
  end

  describe '.find_or_create_user' do
    let(:auth) do
      double('auth',
        info: double(
          email: 'newuser@example.com',
          uid: '12345',
          name: 'New User',
          principal_name: 'newuser@example.com',
          person_affiliation: 'faculty'
        )
      )
    end

    context 'when user exists' do
      let!(:existing_user) { create(:user, email: 'newuser@example.com') }

      it 'returns existing user' do
        result = User.find_or_create_user(auth)
        expect(result).to eq(existing_user)
      end
    end

    context 'when user does not exist' do
      it 'creates new user' do
        expect {
          User.find_or_create_user(auth)
        }.to change(User, :count).by(1)
      end

      it 'assigns auth attributes to new user' do
        user = User.find_or_create_user(auth)
        expect(user.email).to eq('newuser@example.com')
        expect(user.uniqname).to eq('newuser')
        expect(user.uid).to eq('12345')
        expect(user.display_name).to eq('New User')
        expect(user.principal_name).to eq('newuser@example.com')
        expect(user.person_affiliation).to eq('faculty')
      end
    end
  end

  describe '.user_attributes_from_auth' do
    let(:auth) do
      double('auth',
        info: double(
          email: 'test@example.com',
          uid: '67890',
          name: 'Test User',
          principal_name: 'test@example.com',
          person_affiliation: 'staff'
        )
      )
    end

    it 'extracts correct attributes from auth' do
      attrs = User.user_attributes_from_auth(auth)
      expect(attrs).to eq({
        email: 'test@example.com',
        uniqname: 'test',
        uid: '67890',
        principal_name: 'test@example.com',
        display_name: 'Test User',
        person_affiliation: 'staff'
      })
    end
  end

  describe 'factory' do
    it 'creates valid user' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates user with unique email' do
      user1 = create(:user)
      user2 = create(:user)
      expect(user1.email).not_to eq(user2.email)
    end
  end
end