module RequestAPI
  def body_json(symbolize_keys: false)
    json = JSON.parse(response.body)
    symbolize_keys ? json.deep_symbolize_keys : json
  rescue
    return {} 
  end

  def encode_token(payload)
    JWT.encode(payload, 'secret', 'HS256')
  end

  def auth_header(user = nil, merge_with: {})
    user ||= create(:user)
    token = encode_token({ user_id: user.id })
    header = {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
    header.merge(merge_with)
  end
end

RSpec.configure do |config|
  config.include RequestAPI, type: :request
end