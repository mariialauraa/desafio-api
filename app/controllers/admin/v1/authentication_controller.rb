module Admin::V1
  class AuthenticationController < ApplicationController
  
    def login
      service = AuthenticationService.new(login: user_params[:login], password: user_params[:password])

      @user = service.authenticate
      token = encode_token(user_id: @user.id)
      render json: { user: @user, token: token }, status: :ok
    rescue => e
      handle_authentication_error(e.message)
    end

    def logout
      # decodifica o token para obter as informações do usuário
      user_info = decode_token

      if user_info
        service = AuthenticationService.new(login: user_info[0]['login'], password: user_info[0]['password'])
        service.logout(user_info[0]['user_id'])
        render json: { message: 'Logout realizado com sucesso' }, status: :ok
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

    def handle_authentication_error(message)
      case message
      when 'Senha inválida'
        render json: { error: 'Senha inválida' }, status: :unprocessable_entity
      else
        render json: { error: 'Usuário não encontrado' }, status: :not_found
      end
    end
  end
end
