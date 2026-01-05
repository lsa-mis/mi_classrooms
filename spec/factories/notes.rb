FactoryBot.define do
  factory :note do
    association :user
    body { Faker::Lorem.paragraph }
    alert { false }

    # Polymorphic association - defaults to room
    transient do
      noteable { nil }
    end

    after(:build) do |note, evaluator|
      if evaluator.noteable
        note.noteable = evaluator.noteable
      else
        building = create(:building, bldrecnbr: Faker::Number.unique.number(digits: 7))
        note.noteable = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: Faker::Number.unique.number(digits: 7))
      end
    end

    trait :alert do
      alert { true }
    end

    trait :notice do
      alert { false }
    end

    trait :for_room do
      # Default behavior
    end

    trait :for_building do
      after(:build) do |note|
        note.noteable = create(:building, bldrecnbr: Faker::Number.unique.number(digits: 7))
      end
    end
  end
end
