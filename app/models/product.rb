class Product < ApplicationRecord
  include LikeSearchable
  include Paginatable

  has_many :order_products

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :ballast, presence: true
end
