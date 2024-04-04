class SortedOrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product
  
  validates :order_id, presence: true
  validates :product_id, presence: true
  validates :layer, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validates :box, inclusion: { in: [true, false] }
  validate :check_box_uniqueness
end