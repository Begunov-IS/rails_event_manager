FactoryBot.define do
  factory :category do
    title { Faker::Book.genre }
  end
end
