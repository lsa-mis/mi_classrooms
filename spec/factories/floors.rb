FactoryBot.define do
  factory :floor do
    floor { Faker::Number.between(from: 1, to: 10).to_s }
    building_bldrecnbr { Faker::Number.number(digits: 7) }

    after(:build) do |floor|
      floor.floor_plan.attach(
        io: StringIO.new("fake image content"),
        filename: 'floor_plan.png',
        content_type: 'image/png'
      )
    end
  end
end
