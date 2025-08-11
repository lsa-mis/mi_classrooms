FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    uid { SecureRandom.uuid }
    uniqname { email.split('@').first }
    display_name { Faker::Name.name }
    principal_name { email }
    person_affiliation { ["faculty", "staff", "student"].sample }
  end

  factory :announcement do
    location { ["find_a_room_page", "homepage"].sample }
  end

  factory :note do
    body { Faker::Lorem.paragraph }
    alert { false }
    association :user
    association :noteable, factory: :room
  end

  factory :floor do
    floor { ["B", "1", "2", "3", "4", "5"].sample }
    association :building
    
    after(:build) do |floor|
      # Create a minimal valid file for floor_plan attachment
      floor.floor_plan.attach(
        io: StringIO.new("fake floor plan content"),
        filename: 'floor_plan.pdf',
        content_type: 'application/pdf'
      )
    end
  end

  factory :api_update_log do
    result { Faker::Lorem.paragraph }
    status { ["success", "failed", "in_progress"].sample }
  end

  factory :campus_record do
    code { Faker::Alphanumeric.alpha(number: 3).upcase }
    description { Faker::Company.name }
  end

  factory :omni_auth_service do
    provider { "saml" }
    uid { SecureRandom.uuid }
    association :user
  end
end
