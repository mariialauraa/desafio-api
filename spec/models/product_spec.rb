require 'rails_helper'

RSpec.describe Product, type: :model do
  subject { build(:product) } #cria uma instância padrão de 'Product'

  it { is_expected.to have_many(:order_products) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_presence_of(:ballast) }

  it_behaves_like "like searchable concern", :product, :name
  it_behaves_like "paginatable concern", :product
end