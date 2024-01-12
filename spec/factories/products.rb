FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "#{Faker::Food.dish} #{n}" }
    sequence(:ballast) { |n| "Lastro #{n}" }
  end
end