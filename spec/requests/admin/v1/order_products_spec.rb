require 'rails_helper'

RSpec.describe "Admin::V1::OrderProducts", type: :request do
  let(:user) { create(:user) }
  let!(:order) { create(:order) }
  let!(:product) { create(:product) }

  context "POST /admin/v1/order_products" do
    let(:url) { "/admin/v1/order_products?order_id=#{order.id}" }

    context "with valid params" do
      let(:order_product_params) do
        {
          order_product: {
            product_id: product.id,
            quantity: 5,
            box: true
          }
        }.to_json
      end

      it 'adds a new OrderProduct' do
        expect {
          post url, headers: auth_header(user), params: order_product_params
        }.to change(OrderProduct, :count).by(1)
      end

      it 'returns success status and the created order product' do
        post url, headers: auth_header(user), params: order_product_params
        expect(response).to have_http_status(:ok)
        expect(body_json['order_product']).to include({
          'product_id' => product.id,
          'quantity' => 5,
          'box' => true
        })
      end

      it 'returns the last added OrderProduct' do
        post url, headers: auth_header(user), params: order_product_params
        expected_order_product = OrderProduct.last.as_json(only: [:order_id, :product_id, :quantity, :box])
        expect(body_json['order_product'].slice('order_id', 'product_id', 'quantity', 'box')).to eq expected_order_product.stringify_keys
      end

      it 'returns success status' do
        post url, headers: auth_header(user), params: order_product_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:order_product_invalid_params) do
        { order_product: attributes_for(:order_product, product_id: nil, quantity: 5, box: false) }.to_json
      end
    
      it 'does not add a new OrderProduct' do
        expect do
          post url, headers: auth_header(user), params: order_product_invalid_params
        end.to_not change(OrderProduct, :count)
      end
    
      it 'returns error messages' do
        post url, headers: auth_header(user), params: order_product_invalid_params
        expect(body_json['errors']['fields']).to have_key('product_id')
      end
    
      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: order_product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end    
  end

  context "GET /order_products/:id" do
    let(:order_product) { create(:order_product) }
    let(:url) { "/admin/v1/order_products/#{order_product.id}" }
  
    it "returns requested OrderProduct" do
      get url, headers: auth_header(user)
      expected_order_product = OrderProduct.last.as_json(only: [:order_id, :product_id, :quantity, :box])
      expect(body_json['order_product'].slice('order_id', 'product_id', 'quantity', 'box')).to eq expected_order_product.stringify_keys
    end
  
    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "PATCH /order_products/:id" do
    let(:order_product) { create(:order_product) }
    let(:url) { "/admin/v1/order_products/#{order_product.id}" }
  
    context "with valid params" do
      let(:new_quantity) { 10 }
      let(:new_box) { false }
      let(:order_product_params) { { order_product: { quantity: new_quantity, box: new_box } }.to_json }
  
      it 'updates OrderProduct' do
        patch url, headers: auth_header(user), params: order_product_params
        order_product.reload 
        expect(order_product.quantity).to eq new_quantity
        expect(order_product.box).to eq new_box
      end
  
      it 'returns updated OrderProduct' do
        patch url, headers: auth_header(user), params: order_product_params
        order_product.reload
        expected_order_product = OrderProduct.last.as_json(only: [:order_id, :product_id, :quantity, :box])
        expect(body_json['order_product'].slice('order_id', 'product_id', 'quantity', 'box')).to eq expected_order_product.stringify_keys
      end
  
      it 'returns success status' do
        patch url, headers: auth_header(user), params: order_product_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:order_invalid_params) do
        { order_product: { quantity: nil } }.to_json
      end
    
      it 'does not update OrderProduct' do
        old_quantity = order_product.quantity
        patch url, headers: auth_header(user), params: order_invalid_params
        order_product.reload
        expect(order_product.quantity).to eq old_quantity
      end
    
      it 'returns error message' do
        patch url, headers: auth_header(user), params: order_invalid_params
        expect(body_json['errors']['fields']).to have_key('quantity')
      end
    
      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: order_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end    
  end 
  
  context "DELETE /order_products/:id" do
    let!(:order_product) { create(:order_product) }
    let(:url) { "/admin/v1/order_products/#{order_product.id}" }
  
    it 'removes OrderProduct' do
      expect do  
        delete url, headers: auth_header(user)
      end.to change(OrderProduct, :count).by(-1)
    end
  
    it 'returns success status' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end
  
    it 'does not return any body content' do
      delete url, headers: auth_header(user)
      expect(body_json).to be_empty
    end
  end  
end