class ApplicationController < ActionController::API
  def encode_token(payload)
    JWT.encode(payload,'secret')
  end

  #metódo para decodificar o token
  def decode_token
    auth_header = request.headers['Authorization']
    if auth_header
      token = auth_header.split(' ').last
    begin
      JWT.decode(token,'secret', true, algorithm: 'HS256')
    rescue JWT::DecodeError
      nil
    end
  end
  end 

  #método para autorizar o usuário
  def authorized_user
    decoded_token = decode_token()
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  #método para autorizar as ações dentro do sistema
  def authorize
    render json: {message: 'Você precisa estar logado'}, status: :unauthorized unless authorized_user
  end

  #método específico para renderizar os erros
  def render_error(message: nil, fields: nil, status: :unprocessable_entity)
    errors = {}
    errors['fields'] = fields if fields.present?
    errors['message'] = message if message.present?
    render json: { errors: errors }, status: status
  end

  #método para autenticar um usuário
  def authenticate_user(login, password)
    service = AuthenticationService.new(login: login, password: password)
    user = service.authenticate
    return service.generate_token(user.id) if user
    nil
  end

  def logout_user(user_id)
    service = AuthenticationService.new(login: nil, password: nil)
    service.logout(user_id)
  rescue => e    
    Rails.logger.error("Erro ao realizar logout: #{e.message}")
  end
end