module Admin::V1 
  class UsersController < ApplicationController
    before_action :authorize, except: :create
    before_action :load_user, only: [:update, :destroy]    
    
    def login
      service = AuthenticationService.new(login: user_params[:login], password: user_params[:password])

      @user = service.authenticate
      token = service.generate_token(@user.id)
      render json: { user: @user, token: token }, status: :ok
    rescue => e
      handle_authentication_error(e.message)
    end 

    def logout
      service = AuthenticationService.new(login: user_params[:login], password: user_params[:password])
      service.logout(@user.id)
      render json: { message: 'Logout realizado com sucesso' }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
    
    def index
      @users = User.limit(10)
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

    def update
      @user = User.find(params[:id])
      
      if @user.update(user_params)
        render json: { user: @user }, status: :ok
      else
        render json: { error: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      
      if @user.destroy
        render json: { message: 'Usuário deletado com sucesso' }, status: :ok
      else
        render json: { error: 'Não foi possível deletar o usuário' }, status: :unprocessable_entity
      end
    end

    private

    def load_user
      @user = User.find(params[:id])
      render json: { error: 'Usuário não encontrado' }, status: :not_found unless @user
    end
    
    def user_params
      return {} unless params.has_key?(:user)
      params.permit(:name, :login, :password)
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