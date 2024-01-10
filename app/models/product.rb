class Product < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :ballast, presence: true

  has_one_attached :image
  validates :image, presence: true
end
