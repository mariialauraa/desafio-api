require 'rails_helper'

RSpec.describe "Admin::V1::Products", type: :request do
  let(:user) { create(:user) }

  context "GET /products" do
    let(:url) { "/admin/v1/products" }
    let!(:products) { create_list(:product, 5) }

    it "returns all Products" do
      get url, headers: auth_header(user)
      expect(body_json['products']).to contain_exactly *products.as_json(only: %i(id name ballast))
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "POST /products" do
    let(:url) { "/admin/v1/products" }
    
    context "with valid params" do
      let(:product_params) { { product: attributes_for(:product) }.to_json }
    
      it 'adds a new Product' do
        expect do
        post url, headers: auth_header(user), params: product_params
        end.to change(Product, :count).by(1)
      end
    
      it 'returns last added Product' do
        post url, headers: auth_header(user), params: product_params
        expected_product = Product.last.as_json(only: %i(id name ballast))
        expect(body_json['product']).to eq expected_product
      end
    
      it 'returns success status' do
        post url, headers: auth_header(user), params: product_params
        expect(response).to have_http_status(:ok)
      end
    end
    
    context "with invalid params" do
      let(:product_invalid_params) do
        { product: attributes_for(:product, name: nil) }.to_json
      end
    
      it 'does not add a new Product' do
        expect do
        post url, headers: auth_header(user), params: product_invalid_params
        end.to_not change(Product, :count)
      end
    
      it 'returns error message' do
        post url, headers: auth_header(user), params: product_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end
    
      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "PATCH /products/:id" do
    let(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    context "with valid params" do
      let(:new_name) { 'My new Product' }
      let(:product_params) { { product: { name: new_name } }.to_json }

      it 'updates Product' do
        patch url, headers: auth_header(user), params: product_params
        product.reload
        expect(product.name).to eq new_name
      end

      it 'returns updated Product' do
        patch url, headers: auth_header(user), params: product_params
        product.reload
        expected_product = product.as_json(only: %i(id name ballast))
        expect(body_json['product']).to eq expected_product
      end

      it 'returns success status' do
        patch url, headers: auth_header(user), params: product_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:product_invalid_params) do
        { product: attributes_for(:product, name: nil) }.to_json
      end

      it 'does not update Product' do
        old_name = product.name
        patch url, headers: auth_header(user), params: product_invalid_params
        product.reload
        expect(product.name).to eq old_name
      end

      it 'returns error message' do
        patch url, headers: auth_header(user), params: product_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "DELETE /products/:id" do
    let!(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    it 'removes Product' do
      expect do  
        delete url, headers: auth_header(user)
      end.to change(Product, :count).by(-1)
    end

    it 'returns success status' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it 'does not return any body content' do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end
  end

end