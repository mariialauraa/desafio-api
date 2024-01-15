require 'jwt'

class AuthenticationService
  BLACKLIST = Set.new
  
  def initialize(login:, password:)
    @login = login
    @password = password
  end

  # método para autenticar um usuário
  def authenticate
    user = User.find_by(login: @login)
    if user && user.authenticate(@password)
      return user unless BLACKLIST.include?(user.id)
    end
    
    raise 'Senha inválida ou usuário não encontrado'
  end

  # gera um token JWT para um usuário específico
  def generate_token(user_id)
    payload = { user_id: user_id, timestamp: Time.now.to_i }
    JWT.encode(payload, 'secret', 'HS256')
  end

  def logout(user_id)
    token = generate_token(user_id)
    BLACKLIST.add(token)
    cleanup_blacklist
  end

  private

  # define o tempo para manter os tokens na lista negra
  def cleanup_blacklist    
    expiration_time = 24 * 60 * 60  # 24 horas em segundos
  
    # filtra os tokens expirados e remove-os da lista negra
    BLACKLIST.delete_if { |token| expired?(extract_timestamp(token), expiration_time) }
  end

  # extrai o timestamp do token
  def extract_timestamp(token)
    decoded_token = JWT.decode(token, 'secret', true, algorithm: 'HS256')[0]
    decoded_token['timestamp']
  end

  # verifica se o token está expirado
  def expired?(timestamp, expiration_time)    
    current_time = Time.now.to_i
    (current_time - timestamp) > expiration_time
  end
end