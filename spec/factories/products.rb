FactoryBot.define do
    factory :product do
      sequence(:name) { |n| "Product #{n}" }
      sequence(:ballast) { |n| "Ballast #{n}" }
      image { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/images/product_image.png")) }
    end
  end