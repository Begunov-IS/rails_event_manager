FactoryBot.define do
  factory :attendance do
    association :event
    association :user
    checked_in_at { nil }
  end
end
