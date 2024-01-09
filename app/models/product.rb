class Product < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :ballast, presence: true
end
