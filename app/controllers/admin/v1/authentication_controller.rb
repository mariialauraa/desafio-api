module Admin::V1
  class AuthenticationController < ApplicationController
  
    def login
      service = AuthenticationService.new(login: user_params[:login], password: user_params[:password])

      @user = service.authenticate
      token = encode_token(user_id: @user.id)
      render json: { user: @user, token: token }, status: :ok
    rescue => e
        render json: { error: 'Usuário não encontrado ou Senha inválida' }, status: :not_found
    end

    def logout
      # obtém o token do cabeçalho da requisição
      authorization_header = request.headers['Authorization']
    
      if authorization_header.present? && authorization_header.split(' ').length == 2
        token = authorization_header.split(' ').last
        service = AuthenticationService.new(login: nil, password: nil)
        
        if service.logout(token)
          render json: { message: 'Logout realizado com sucesso' }, status: :ok
        else
          render json: { error: 'Erro ao realizar logout' }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Token inválido ou ausente' }, status: :unauthorized
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end    

    private

    def user_params
      return {} unless params.has_key?(:user)
      params.require(:user).permit(:login, :password)
    end
  end
end
