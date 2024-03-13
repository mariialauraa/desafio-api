FactoryBot.define do
  factory :order_product do
    order_id { 1 }
    product_id { 1 }
    quantity { "1" }
    box { false }
  end
end
