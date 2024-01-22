require 'rails_helper'

RSpec.describe "Admin V1 Authentication as :admin", type: :request do

  context 'POST /login' do
    let(:url) { "/admin/v1/login" }

    context 'with valid credentials' do
      it 'returns a success response with user and token' do
        user = create(:user, login: 'valid_user', password: 'valid_password', password_confirmation: 'valid_password')

        post url, params: { user: { login: 'valid_user', password: 'valid_password' } }

        body = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(body['user']['id']).to eq(user.id)
        expect(body['token']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns an error response' do
        post url, params: { user: { login: 'invalid_user', password: 'invalid_password', password_confirmation: 'invalid_password' } }

        expect(response).to have_http_status(:not_found)
        
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Usuário não encontrado ou Senha inválida')
      end
    end
  end

  context 'POST /logout' do
    let(:url) { "/admin/v1/logout" }
  
    context 'with a valid token' do
      it 'logs out the user and returns a success response' do
        user = create(:user, login: 'valid_user', password: 'valid_password', password_confirmation: 'valid_password')
        token = encode_token(user_id: user.id)

        post url, headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['message']).to eq('Logout realizado com sucesso')
      end
    end

    context 'with an invalid token' do
      it 'returns an unauthorized response' do
        post url, headers: { 'Authorization' => "Bearer #{}" }

        expect(response).to have_http_status(:unauthorized)

        body = JSON.parse(response.body)
        expect(body['error']).to eq('Token inválido ou ausente')
      end
    end
  end
end