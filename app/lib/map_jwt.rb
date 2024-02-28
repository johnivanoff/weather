class MapJwt
  attr_reader :jwt

  def initialize
    @jwt = generate_jwt
  end

  private
    def generate_jwt
      JWT.encode(payload, private_key, "ES256", header)
    end

    def header
      {
        "alg" => "ES256",
        "kid" => Rails.application.credentials.dig(:map, :apple_key_id),
        "typ": "JWT"
      }
    end

    def payload
      {
        "iss" => Rails.application.credentials.dig(:team_id),
        "iat" => Time.now.to_i,
        "exp" => Time.now.to_i + 60 * 60 * 24 * 30 * 5, # Expire in 5 months
        "sub" => Rails.application.credentials.dig(:map, :client_id)
      }
    end

    def private_key
      OpenSSL::PKey.read(Rails.application.credentials.dig(:map, :private_key))
    end
end
