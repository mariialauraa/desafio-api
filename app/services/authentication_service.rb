class AuthenticationService
  
  def initialize(login:, password:)
    @login = login
    @password = password
  end

  # método para autenticar um usuário
  def authenticate
    user = User.find_by(login: @login)
    return user if user && user.authenticate(@password)
    
    raise 'Senha inválida ou usuário não encontrado'
  end

  # gerar um token JWT para um usuário específico
  def generate_token(user_id)
    payload = { user_id: user_id }
    JWT.encode(payload, 'secret', 'HS256')
  end
end