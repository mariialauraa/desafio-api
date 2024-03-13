class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order

  validates :order_id, presence: true
  validates :product_id, presence: true
  validates :quantity, presence: true
  validates :box, inclusion: { in: [true, false] }
end
