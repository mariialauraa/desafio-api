class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order

  validates :order_id, presence: true
  validates :product_id, presence: true
  validates :quantity, presence: true
  validates :box, inclusion: { in: [true, false] }

  validate :check_box_uniqueness

  private

  def check_box_uniqueness
    if OrderProduct.where(product_id: product_id, box: box).where.not(id: id).exists?
      errors.add(:box, "Já existe um produto com o mesmo product_id e box definido como #{box ? 'true' : 'false'}")
    end
  end
end
