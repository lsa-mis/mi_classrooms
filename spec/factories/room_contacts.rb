FactoryBot.define do
  factory :room_contact do
    rmrecnbr             { Faker::Number.number(digits: 7) }
    rm_schd_cntct_name   { Faker::String.random(length: 6..60) }
    rm_schd_email        { Faker::Internet.email }
    rm_schd_cntct_phone  { Faker::PhoneNumber.phone_number }
    rm_det_url           { Faker::Internet.url }
    rm_usage_guidlns_url { Faker::Internet.url }
    rm_sppt_deptid       { Faker::String.random(length: 6..10) }
    rm_sppt_dept_descr   { Faker::String.random(length: 6..60) }
    rm_sppt_cntct_email  { Faker::Internet.email }
    rm_sppt_cntct_phone  { Faker::PhoneNumber.phone_number }
    rm_sppt_cntct_url    { Faker::Internet.url }
    
  end
end
