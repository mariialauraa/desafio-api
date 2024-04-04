require 'rails_helper'

RSpec.describe "Admin::V1::Orders", type: :request do
  let(:user) { create(:user) }
  let!(:loads) { create_list(:load, 2) }

  context "GET /orders" do
    let(:url) { "/admin/v1/orders" }
    let!(:orders) { create_list(:order, 10, load: loads.first) }

    context "without any params" do
      it "returns all orders" do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
        expect(body_json['orders'].count).to eq(10)
      end

      it "returns orders with the correct data" do
        get url, headers: auth_header(user)
        expected_orders = orders.as_json(only: %i[id code bay load_id])
        expect(body_json['orders']).to match_array(expected_orders)
      end
    end

    context "with load_id param" do
      let(:load_id) { loads.first.id }
      let(:params) { { load_id: load_id } }

      it "returns orders for the specified load" do
        get url, headers: auth_header(user), params: params
        expect(response).to have_http_status(:ok)
        expect(body_json['orders'].count).to eq(10)
        expect(body_json['orders'].all? { |order| order['load_id'] == load_id }).to be true
      end
    end

    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it "returns records sized by :length" do
        get url, headers: auth_header(user), params: pagination_params
        expect(body_json['orders'].count).to eq length
      end

      it "returns success status" do
        get url, headers: auth_header(user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 2, length: 5, total_pages: 2 } do
        before { get url, headers: auth_header(user), params: pagination_params }
      end
    end

    context "with order params" do
      let(:order_params) { { order: { code: 'desc' } } }

      it "returns ordered products limited by default pagination" do
        get url, headers: auth_header(user), params: order_params
        expected_orders = Order.order(code: :desc).limit(10).as_json(only: %i[id code bay load_id])
        expect(body_json['orders']).to contain_exactly(*expected_orders)
      end
 
      it "returns success status" do
        get url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user), params: order_params }
      end
    end
  end

  context "POST /orders" do
    let(:load) { loads.first }
    let(:url) { "/admin/v1/orders?load_id=#{load.id}" } 
  
    context "with valid params" do
      let(:order_params) do
        {
          order: {
            code: "12345",
            bay: "D1",
            load_id: load.id 
          }
        }.to_json
      end
  
      it 'adds a new Order' do
        expect do
          post url, headers: auth_header(user), params: order_params
        end.to change(Order, :count).by(1)
      end

      it 'returns success status and the created order' do
        post url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok) 
        expect(body_json['order']).to include({
          'code' => '12345',
          'bay' => 'D1',
        })
      end

      it 'returns the last added Order' do
        post url, headers: auth_header(user), params: order_params
        expected_order = Order.last.as_json(only: %i[id code bay load_id])
        expect(body_json['order']).to eq expected_order
      end
      
      it 'returns success status' do
        post url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok)
      end      
    end

    context "with invalid params" do
      let(:order_invalid_params) do
        { order: attributes_for(:order, code: nil, load_id: loads.first.id) }.to_json
      end
    
      it 'does not add a new Order' do
        expect do
          post url, headers: auth_header(user), params: order_invalid_params
        end.to_not change(Order, :count)
      end
    
      it 'returns error message' do
        post url, headers: auth_header(user), params: order_invalid_params
        expect(body_json['errors']['fields']).to have_key('code')
      end
    
      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: order_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end    
  end

  context "GET /orders/:id" do
    let(:order) { create(:order, load: loads.first) }
    let(:url) { "/admin/v1/orders/#{order.id}" }
  
    it "returns requested Order" do
      get url, headers: auth_header(user)
      expected_order = order.as_json(only: %i(id code bay load_id))
      expect(body_json['order']).to eq expected_order
    end
  
    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "PATCH /orders/:id" do
    let(:order) { create(:order, load: loads.first) } 
    let(:url) { "/admin/v1/orders/#{order.id}" }
  
    context "with valid params" do
      let(:new_code) { 'UpdatedOrder123' }
      let(:new_bay) { 'UpdatedBay' }
      let(:order_params) { { order: { code: new_code, bay: new_bay } }.to_json }
  
      it 'updates Order' do
        patch url, headers: auth_header(user), params: order_params
        order.reload 
        expect(order.code).to eq new_code
        expect(order.bay).to eq new_bay
      end
  
      it 'returns updated Order' do
        patch url, headers: auth_header(user), params: order_params
        order.reload
        expected_order = order.as_json(only: %i(id code bay load_id))
        expect(body_json['order']).to eq expected_order
      end
  
      it 'returns success status' do
        patch url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:order_invalid_params) do
        { order: { code: nil } }.to_json 
      end
    
      it 'does not update Order' do
        old_code = order.code
        patch url, headers: auth_header(user), params: order_invalid_params
        order.reload
        expect(order.code).to eq old_code
      end
    
      it 'returns error message' do
        patch url, headers: auth_header(user), params: order_invalid_params
        expect(body_json['errors']['fields']).to have_key('code') 
      end
    
      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: order_invalid_params
        expect(response).to have_http_status(:unprocessable_entity) 
      end
    end
  end

  context "DELETE /orders/:id" do
    let!(:order) { create(:order, load: loads.first) } 
    let(:url) { "/admin/v1/orders/#{order.id}" }
  
    it 'removes Order' do
      expect do  
        delete url, headers: auth_header(user)
      end.to change(Order, :count).by(-1)
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