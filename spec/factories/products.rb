FactoryBot.define do
    factory :product do
      sequence(:name) { |n| "Product #{n}" }
      sequence(:ballast) { |n| "Ballast #{n}" }
    end
  end