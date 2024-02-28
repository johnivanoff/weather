class WeatherJwt
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
        "kid" => Rails.application.credentials.dig(:APPLE_KEY_ID)
      }
    end

    def payload
      {
        "iss" => Rails.application.credentials.dig(:TEAM_ID),
        "iat" => Time.now.to_i,
        "exp" => Time.now.to_i + 60 * 60 * 24 * 30 * 5, # Expire in 5 months
        "sub" => Rails.application.credentials.dig(:CLIENT_ID)
      }
    end

    def private_key
      OpenSSL::PKey.read(Rails.application.credentials.dig(:PRIVATE_KEY))
    end
end
