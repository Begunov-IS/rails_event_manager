FactoryBot.define do
  factory :event do
    title { Faker::Lorem.sentence(word_count: 3) }
    location { Faker::Address.city }
    from_date { 2.days.from_now }
    to_date { 2.days.from_now + 3.hours }
    association :owner, factory: :user
    category { nil }
    venue { nil }
  end
end
