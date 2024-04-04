FactoryBot.define do
  factory :order do
    code { Faker::Commerce.unique.promotion_code(digits: 4) }
    bay { "D1" }
    association :load
  end
end
