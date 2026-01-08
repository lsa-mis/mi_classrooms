FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    uniqname { Faker::Internet.username(specifier: 5..8) }
    display_name { Faker::Name.name }
    principal_name { "#{Faker::Internet.username}@umich.edu" }
  end
end
