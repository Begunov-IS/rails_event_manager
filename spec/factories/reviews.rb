FactoryBot.define do
  factory :review do
    association :event
    association :user
    review_text { Faker::Lorem.sentence }
    rating { Faker::Number.between(from: 1, to: 5) }
    status { 'published' }
  end
end
