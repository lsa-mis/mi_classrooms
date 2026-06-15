FactoryBot.define do
  factory :page_view do
    sequence(:session_token) { |n| Digest::SHA256.hexdigest("session-#{n}")[0, 32] }
    user { nil }
    controller_name { "rooms" }
    action_name { "index" }
    path { "/rooms" }
    referrer_host { nil }
    device_type { "desktop" }
    http_status { 200 }
    duration_ms { 42 }
    occurred_at { Time.current }

    trait :authenticated do
      association :user
    end

    trait :mobile do
      device_type { "mobile" }
    end

    trait :bot do
      device_type { "bot" }
    end
  end
end
