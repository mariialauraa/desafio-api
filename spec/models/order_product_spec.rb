require 'rails_helper'

RSpec.describe OrderProduct, type: :model do
  it { is_expected.to belong_to :order }
  it { is_expected.to belong_to :product }

  it { is_expected.to validate_presence_of(:order_id) }
  it { is_expected.to validate_presence_of(:product_id) }
  it { is_expected.to validate_presence_of(:quantity) } 

  it "should validate box as boolean" do
    order_product = OrderProduct.new(box: true)
    expect(order_product.box).to eq(true).or eq(false)
  end
end
