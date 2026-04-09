FactoryBot.define do
  factory :venue do
    name { Faker::Company.name }
    city { Faker::Address.city }
    address { Faker::Address.street_address }
    capacity { Faker::Number.between(from: 100, to: 50000) }
  end
end
