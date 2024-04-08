FactoryBot.define do
  factory :load do
    code { Faker::Commerce.unique.promotion_code(digits: 4) }
    delivery_date { 1.days.from_now }
  end
end