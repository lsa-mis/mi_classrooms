FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    sequence(:uniqname) { |n| "user#{n}" }
    display_name { Faker::Name.name }
    principal_name { "#{Faker::Internet.username}@umich.edu" }
  end
end
