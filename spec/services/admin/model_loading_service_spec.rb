require "rails_helper"

describe Admin::ModelLoadingService do
  context "when #call" do
    let!(:products) { create_list(:product, 15) }

    context "when params are present" do
      let!(:search_products) do
        products = []
        15.times { |n| products << create(:product, name: "Search #{n + 1}") }
        products
      end

      let(:params) do
        { search: { name: "Search" }, order: { name: :desc }, page: 2, length: 4 }
      end

      it "returns right :length following pagination" do
        service = described_class.new(Product.all, params)
        result_products = service.call
        expect(result_products.count).to eq 4
      end

      it "returns records following search, order and pagination" do
        search_products.sort! { |a, b| b[:name] <=> a[:name] }
        service = described_class.new(Product.all, params)
        result_products = service.call
        expected_products = search_products[4..7]
        expect(result_products).to contain_exactly *expected_products
      end
    end

    context "when params are not present" do
      it "returns default :length pagination" do
        service = described_class.new(Product.all, nil)
        result_products = service.call
        expect(result_products.count).to eq 10
      end

      it "returns first 10 records" do
        service = described_class.new(Product.all, nil)
        result_products = service.call
        expected_products = products[0..9]
        expect(result_products).to contain_exactly *expected_products
      end
    end
  end
end