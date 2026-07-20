FactoryBot.define do
  factory :sponsor do
    name { Faker::Company.name }
    email { Faker::Internet.email }
  end
end
