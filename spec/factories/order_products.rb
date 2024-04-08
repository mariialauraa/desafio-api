FactoryBot.define do
  factory :order_product do
    association :order
    association :product
    quantity { 1 }
    box { Faker::Boolean.boolean }
  end
end
