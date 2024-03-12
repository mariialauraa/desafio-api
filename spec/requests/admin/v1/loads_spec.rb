require 'rails_helper'

RSpec.describe "Admin::V1::Loads", type: :request do
  let(:user) { create(:user) }

  context "GET /loads" do
    let(:url) { "/admin/v1/loads" }
    let!(:loads) { create_list(:load, 10) }

    context "without any params" do
      it "returns 10 Loads" do
        get url, headers: auth_header(user)
        expect(body_json['loads'].count).to eq 10
      end
      
      it "returns 10 first Loads" do
        get url, headers: auth_header(user)
        expected_loads = loads[0..9].as_json(only: %i(id code delivery_date))
        expect(body_json['loads']).to contain_exactly *expected_loads
      end

      it "returns success status" do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user) }
      end
    end

    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it "returns records sized by :length" do
        get url, headers: auth_header(user), params: pagination_params
        expect(body_json['loads'].count).to eq length
      end

      it "returns success status" do
        get url, headers: auth_header(user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 2, length: 5, total_pages: 2 } do
        before { get url, headers: auth_header(user), params: pagination_params }
      end
    end
  end

  context "POST /loads" do
    let(:url) { "/admin/v1/loads" }
    
    context "with valid params" do
      let(:load_params) { { load: attributes_for(:load) }.to_json }
    
      it 'adds a new load' do
        expect do
        post url, headers: auth_header(user), params: load_params
        end.to change(Load, :count).by(1)
      end
    
      it 'returns last added Load' do
        post url, headers: auth_header(user), params: load_params
        expected_load = Load.last.as_json(only: %i(id code delivery_date))
        expect(body_json['load']).to eq expected_load
      end
    
      it 'returns success status' do
        post url, headers: auth_header(user), params: load_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:load_invalid_params) do
        { load: attributes_for(:load, code: nil) }.to_json
      end
    
      it 'does not add a new Load' do
        expect do
        post url, headers: auth_header(user), params: load_invalid_params
        end.to_not change(Load, :count)
      end
    
      it 'returns error message' do
        post url, headers: auth_header(user), params: load_invalid_params
        expect(body_json['errors']['fields']).to have_key('code')
      end
    
      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: load_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "GET /loads/:id" do
    let(:load) { create(:load) }
    let(:url) { "/admin/v1/loads/#{load.id}" }

    it "returns requested Load" do
      get url, headers: auth_header(user)
      expected_load = load.as_json(only: %i(id code delivery_date))
      expect(body_json['load']).to eq expected_load
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "PATCH /loads/:id" do
    let(:load) { create(:load) }
    let(:url) { "/admin/v1/loads/#{load.id}" }

    context "with valid params" do
      let(:new_code) { 'NEWCODE' }
      let(:load_params) { { load: { code: new_code } }.to_json }

      it 'updates Load' do
        patch url, headers: auth_header(user), params: load_params
        load.reload
        expect(load.code).to eq new_code
      end

      it 'returns updated Load' do
        patch url, headers: auth_header(user), params: load_params
        load.reload
        expected_load = load.as_json(only: %i(id code delivery_date))
        expect(body_json['load']).to eq expected_load
      end

      it 'returns success status' do
        patch url, headers: auth_header(user), params: load_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:load_invalid_params) do
        { load: attributes_for(:load, code: nil) }.to_json
      end

      it 'does not update Load' do
        old_code = load.code
        patch url, headers: auth_header(user), params: load_invalid_params
        load.reload
        expect(load.code).to eq old_code
      end

      it 'returns error message' do
        patch url, headers: auth_header(user), params: load_invalid_params
        expect(body_json['errors']['fields']).to have_key('code')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: load_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end

  context "DELETE /loads/:id" do
    let!(:load) { create(:load) }
    let(:url) { "/admin/v1/loads/#{load.id}" }

    it 'removes Load' do
      expect do  
        delete url, headers: auth_header(user)
      end.to change(Load, :count).by(-1)
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