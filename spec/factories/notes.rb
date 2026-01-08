FactoryBot.define do
  factory :note do
    association :user
    body { Faker::Lorem.paragraph }
    alert { false }

    # Polymorphic association - defaults to room
    # Pass noteable: to use an existing record instead of creating new ones
    transient do
      noteable { nil }
    end

    after(:build) do |note, evaluator|
      if evaluator.noteable
        note.noteable = evaluator.noteable
      else
        # Use build to avoid DB inserts when using build(:note)
        building = build(:building, bldrecnbr: Faker::Number.unique.number(digits: 7))
        note.noteable = build(:room, building: building, building_bldrecnbr: building.bldrecnbr, rmrecnbr: Faker::Number.unique.number(digits: 7))
      end
    end

    after(:create) do |note|
      # Ensure noteable is persisted when note is created
      note.noteable.save! unless note.noteable.persisted?
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
        note.noteable = build(:building, bldrecnbr: Faker::Number.unique.number(digits: 7))
      end
    end
  end
end
