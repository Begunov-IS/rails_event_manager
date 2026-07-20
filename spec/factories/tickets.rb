FactoryBot.define do
  factory :ticket do
    association :event
    user { nil }
    price { Faker::Commerce.price(range: 10.0..500.0) }
    status { 'available' }
  end
end
