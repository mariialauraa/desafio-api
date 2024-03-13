class Order < ApplicationRecord
  belongs_to :load
  has_many :order_products

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :bay, presence: true
  validates :load_id, presence: true
end
