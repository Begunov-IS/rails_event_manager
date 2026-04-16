FactoryBot.define do
  factory :event_sponsor do
    association :event
    association :sponsor
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
