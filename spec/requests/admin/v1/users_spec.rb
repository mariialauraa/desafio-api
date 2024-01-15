require 'rails_helper'

RSpec.describe "Admin V1 Users as :admin", type: :request do
  let(:login_user) { create(:user) }

  context "GET /users" do
    let(:url) { "/admin/v1/users" }
    let!(:users) { create_list(:user, 10) }
    
    context "without any params" do
      it "returns 10 users" do
        get url, headers: auth_header(login_user)
        expect(body_json['users'].count).to eq 10
      end

      it "returns 10 first Users" do
        get url, headers: auth_header(login_user)
        expected_users = users[0..9].as_json(
          only: %i(id name login)
        )
        expect(body_json['users']).to contain_exactly *expected_users
      end

      it "returns success status" do
        get url, headers: auth_header(login_user)
        expect(response).to have_http_status(:ok)
      end
    end    
  end

  context "POST /users" do
    let(:url) { "/admin/v1/users" }
    
    context "with valid params" do
      let(:user_params) { { user: attributes_for(:user) }.to_json }

      it 'adds a new User' do
        expect do
          post url, headers: auth_header(login_user), params: user_params
        end.to change(User, :count).by(1)
      end
      
      it "returns success status" do
        get url, headers: auth_header(login_user)
        expect(response).to have_http_status(:ok)
      end      
    end

    context "with invalid params" do
      let(:user_invalid_params) do
        { user: attributes_for(:user, name: nil) }.to_json
      end
    
      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(login_user), params: user_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end  

  context "PATCH /users/:id" do
    let(:user) { create(:user) }
    let(:url) { "/admin/v1/users/#{user.id}" }

    context "with valid params" do
      let(:new_name) { 'My new User' }
      let(:user_params) { { user: { name: new_name } }.to_json }

      it 'returns success status' do
        patch url, headers: auth_header(login_user), params: user_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:user_invalid_params) do 
        { user: attributes_for(:user, name: nil) }.to_json
      end

      it 'does not update User' do
        old_name = user.name
        patch url, headers: auth_header(login_user), params: user_invalid_params
        user.reload
        expect(user.name).to eq old_name
      end
    end
  end

  context "DELETE /users/:id" do
    let!(:user) { create(:user) }
    let(:url) { "/admin/v1/users/#{user.id}" }

    it 'returns success status' do
      delete url, headers: auth_header(login_user)
      expect(response).to have_http_status(:ok)
    end

    it 'does not return any body content' do
      delete url, headers: auth_header(login_user)
      expect(body_json).to be_present
    end
  end
end