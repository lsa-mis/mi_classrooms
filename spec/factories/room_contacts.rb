FactoryBot.define do
  factory :room_contact do
    association :room
    rmrecnbr { room&.rmrecnbr || FactoryBot.create(:room).rmrecnbr }
    rm_schd_cntct_name { Faker::Name.name }
    rm_schd_email { Faker::Internet.email }
    rm_schd_cntct_phone { Faker::PhoneNumber.phone_number }
    rm_det_url { Faker::Internet.url }
    rm_usage_guidlns_url { Faker::Internet.url }
    rm_sppt_deptid { Faker::Alphanumeric.alpha(number: 6) }
    rm_sppt_dept_descr { Faker::Educator.subject }
    rm_sppt_cntct_email { Faker::Internet.email }
    rm_sppt_cntct_phone { Faker::PhoneNumber.phone_number }
    rm_sppt_cntct_url { Faker::Internet.url }
  end
end