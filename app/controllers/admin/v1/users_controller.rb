module Admin::V1 
  class UsersController < ApplicationController
    before_action :authorize, except: [:create, :login]
    before_action :load_user, only: [:show, :update, :destroy]    
    
    def login
      service = AuthenticationService.new(login: user_params[:login], password: user_params[:password])

      @user = service.authenticate
      token = encode_token(user_id: @user.id)
      render json: { user: @user, token: token }, status: :ok
    rescue => e
      handle_authentication_error(e.message)
    end 

    def logout
      #decodifica o token para obter as informações do usuário
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
    
    def index
      @loading_service = Admin::ModelLoadingService.new(User.all, searchable_params)
      @loading_service.call
    end
    
    def create
      @user = User.new(user_params)
      if @user.save
        token = encode_token({ user_id: @user.id })
        render json: { user: @user, token: token }, status: :ok
      else
        render json: { error: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end

    def show; end

    def update
      @user.attributes = user_params
      save_user!
    end

    def destroy
      @user.destroy!
    rescue
      render_error(fields: @user.errors.messages)
    end

    private

    def load_user
      @user = User.find(params[:id])
    end

    def searchable_params
      params.permit({ search: :name }, { order: {} }, :page, :length)
    end
    
    def user_params
      return {} unless params.has_key?(:user)
      params.require(:user).permit(:name, :login, :password)
    end

    def save_user!
      @user.save!
      render :show
    rescue
      render_error(fields: @user.errors.messages)
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