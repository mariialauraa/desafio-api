require "rails_helper"

describe Admin::ModelLoadingService do
  context "when #call" do
    let!(:products) { create_list(:product, 15) }
    
    context "when params are present" do
      let!(:search_products) do
        products = []
        15.times do |n| 
          products << create(:product, name: "Search #{n + 1}", ballast: "Lastro 1")
        end
        products
      end

      let!(:unexpected_products) do
        products = []
        15.times do |n| 
          products << create(:product, name: "Search #{n + 16}")
        end
        products
      end
    end

    context "when params are not present" do
      it "returns default :length pagination" do
        service = described_class.new(Product.all, nil)
        service.call
        expect(service.records.count).to eq 10
      end

      it "sets right :page" do
        service = described_class.new(Product.all, nil)
        service.call
        expect(service.pagination[:page]).to eq 1
      end

      it "sets right :length" do
        service = described_class.new(Product.all, nil)
        service.call
        expect(service.pagination[:length]).to eq 10
      end

      it "sets right :total" do
        service = described_class.new(Product.all, nil)
        service.call
        expect(service.pagination[:total]).to eq 15
      end

      it "sets right :total_pages" do
        service = described_class.new(Product.all, nil)
        service.call
        expect(service.pagination[:total_pages]).to eq 2
      end
    end
  end
end